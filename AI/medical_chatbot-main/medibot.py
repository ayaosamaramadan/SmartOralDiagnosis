import os
import uuid
import requests
import streamlit as st
from dotenv import load_dotenv

from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import PromptTemplate
from langchain_groq import ChatGroq
from langchain import hub
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

load_dotenv()

DB_FAISS_PATH = "vectorstore/db_faiss"


@st.cache_resource
def get_vectorstore():
    embedding_model = HuggingFaceEmbeddings(model_name='sentence-transformers/all-MiniLM-L6-v2')
    db = FAISS.load_local(DB_FAISS_PATH, embedding_model, allow_dangerous_deserialization=True)
    return db


def set_custom_prompt(custom_prompt_template):
    prompt = PromptTemplate(template=custom_prompt_template, input_variables=["context", "question"])
    return prompt


def inject_styles():
    """Inject CSS for light/dark themes and allow forcing via ?theme=dark|light"""
    try:
        params = st.query_params
    except Exception:
        params = {}

    forced_theme = None
    if params and 'theme' in params:
        t = params.get('theme')
        if isinstance(t, list):
            forced_theme = t[0]
        else:
            forced_theme = t

    # Load base CSS from external file (keeps the Python source small)
    try:
        css_path = os.path.join(os.path.dirname(__file__), 'embed.css')
        with open(css_path, 'r', encoding='utf-8') as f:
            css_base = f.read()
    except Exception:
        css_base = ''

    # Only a small override block is needed when forcing a theme
    theme_override = ''
    if forced_theme == 'dark':
        theme_override = '<style>:root { --chat-bg: #0b1220; --chat-text: #e6eef8; }</style>'
    elif forced_theme == 'light':
        theme_override = '<style>:root { --chat-bg: #ffffff; --chat-text: #111827; }</style>'

    if css_base:
        st.markdown(css_base + theme_override, unsafe_allow_html=True)


def main():
    try:
        inject_styles()
    except Exception:
        pass

    if 'messages' not in st.session_state:
        st.session_state.messages = []

    for message in st.session_state.messages:
        st.chat_message(message['role']).markdown(message['content'])

    if 'session_id' not in st.session_state:
        st.session_state.session_id = str(uuid.uuid4())

    prompt = st.chat_input("Write your question here...")

    if prompt:
        st.chat_message('user').markdown(prompt)
        st.session_state.messages.append({'role': 'user', 'content': prompt})
        # save user message to backend
        try:
            backend = os.environ.get('NEXT_BACKEND_SERVER', os.environ.get('BACKEND_URL', os.environ.get('NEXT_BACKEND_SERVER')))
            requests.post(f"{backend}/api/chat/messages", json={
                'sessionId': st.session_state.session_id,
                'role': 'user',
                'content': prompt
            }, timeout=5)
        except Exception:
            pass

        CUSTOM_PROMPT_TEMPLATE = """
                Use the pieces of information provided in the context to answer user's question.
                If you dont know the answer, just say that you dont know, dont try to make up an answer. 
                Dont provide anything out of the given context

                Context: {context}
                Question: {question}

                Start the answer directly. No small talk please.
                """

        try:
            vectorstore = get_vectorstore()
            if vectorstore is None:
                st.error("Failed to load the vector store")

            GROQ_API_KEY = os.environ.get('GROQ_API_KEY')
            GROQ_MODEL_NAME = "llama-3.1-8b-instant"

            llm = ChatGroq(
                model=GROQ_MODEL_NAME,
                temperature=0.5,
                max_tokens=512,
                api_key=GROQ_API_KEY
            )

            retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")

            combine_docs_chain = create_stuff_documents_chain(llm, retrieval_qa_chat_prompt)

            rag_chain = create_retrieval_chain(vectorstore.as_retriever(search_kwargs={'k': 3}), combine_docs_chain)

            response = rag_chain.invoke({'input': prompt})

            result = response["answer"]
            st.chat_message('assistant').markdown(result)
            st.session_state.messages.append({'role': 'assistant', 'content': result})

            try:
                backend = os.environ.get('NEXT_BACKEND_SERVER', os.environ.get('BACKEND_URL', 'http://localhost:5000'))
                requests.post(f"{backend}/api/chat/messages", json={
                    'sessionId': st.session_state.session_id,
                    'role': 'assistant',
                    'content': result
                }, timeout=5)
            except Exception:
                pass

        except Exception as e:
            st.error(f"Error: {str(e)}")


if __name__ == "__main__":
    main()