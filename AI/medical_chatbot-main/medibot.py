import os
import streamlit as st
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import PromptTemplate
from langchain_groq import ChatGroq
from langchain import hub
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from dotenv import load_dotenv
import requests
import uuid

load_dotenv()

DB_FAISS_PATH="vectorstore/db_faiss"
@st.cache_resource
def get_vectorstore():
    embedding_model=HuggingFaceEmbeddings(model_name='sentence-transformers/all-MiniLM-L6-v2')
    db=FAISS.load_local(DB_FAISS_PATH, embedding_model, allow_dangerous_deserialization=True)
    return db


def set_custom_prompt(custom_prompt_template):
    prompt=PromptTemplate(template=custom_prompt_template, input_variables=["context", "question"])
    return prompt


def inject_styles():
     st.markdown(
        """
        <style>
        /* CSS variables for light/dark themes */
        :root {
            --chat-bg: #ffffff;
            --chat-text: #0b1220;
            --muted: #6b7280;
            --input-bg: #0f1724; /* default input bg (dark-themed input) */
            --input-border: #374151; /* neutral border in dark */
            --focus: #2563eb; /* blue-600 */
            --assistant-bg: #0b1225; /* subtle assistant bubble dark */
            --user-bg: #08321a; /* subtle user bubble dark */
        }

        @media (prefers-color-scheme: dark) {
            :root {
                --chat-bg: #0b1220;
                --chat-text: #e6eef8;
                --muted: #94a3b8;
                --input-bg: #0b1220;
                --input-border: #1f2937;
                --focus: #60a5fa; /* lighter blue for dark */
                --assistant-bg: #06202b;
                --user-bg: #04321a;
            }
        }

        /* Overall page container */
        .main .block-container {
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            color: var(--chat-text) !important;
            background-color: var(--chat-bg) !important;
        }

        /* Chat messages container spacing */
        [data-testid="stChatMessage"] {
            margin-bottom: 10px;
            display: flex;
            align-items: flex-start;
        }

        /* Hide avatar column for both user and assistant */
        [data-testid="stChatMessage"] > div:first-child { display: none !important; }

        /* Expand message bubble to full width when avatar is removed */
        [data-testid="stChatMessage"] .stMarkdown { max-width: 100% !important; }

        /* Message bubble styling */
        [data-testid="stChatMessage"] .stMarkdown {
            color: var(--chat-text) !important;
            background: var(--assistant-bg) !important;
            border-radius: 12px !important;
            padding: 12px 16px !important;
            box-shadow: 0 1px 4px rgba(2,6,23,0.06);
            max-width: 78%;
            line-height: 1.5;
            border: 1px solid rgba(15,23,42,0.04);
        }

        /* User messages: align right and use user bg */
        [data-testid="stChatMessage"]:nth-child(even) .stMarkdown {
            background: var(--user-bg) !important;
            margin-left: auto !important;
            color: var(--chat-text) !important;
        }

        /* Assistant messages subtle tint */
        [data-testid="stChatMessage"]:nth-child(odd) .stMarkdown {
            background: var(--assistant-bg) !important;
        }

        /* Improve message inner paragraphs */
        [data-testid="stChatMessage"] .stMarkdown p { margin: 0 0 6px 0; }

        /* Chat input styling and focus */
        .stChatInput, .stChatInput > div > div {
            background: var(--input-bg) !important;
            border-radius: 12px !important;
        }

        /* Make the chat input container visually consistent with surrounding div */
        div[data-testid="stChatInput"] {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            padding: 6px 10px !important;
            border-radius: 12px !important;
            background: var(--input-bg) !important;
            border: 1px solid var(--input-border) !important;
            box-shadow: none !important;
            margin: 6px 0 !important;
        }

        /* Make the textarea blend into its container: no extra border or background */
        div[data-testid="stChatInput"] textarea[data-testid="stChatInputTextArea"] {
            background: transparent !important;
            border: none !important;
            padding: 8px 6px !important;
            margin: 0 !important;
            color: var(--chat-text) !important;
            width: 100% !important;
            resize: none !important;
            line-height: 1.4 !important;
        }

        /* When the textarea is focused, show blue ring on the container, not red on inner element */
        div[data-testid="stChatInput"]:focus-within {
            box-shadow: 0 0 0 6px rgba(37,99,235,0.08) !important;
            border-color: var(--focus) !important;
        }

        /* Input field focus: force blue outline, remove red completely */
        /* Target Streamlit chat textarea specifically plus general text inputs */
        textarea[data-testid="stChatInputTextArea"],
        [data-testid="stChatInputTextArea"],
        .stChatInput textarea,
        .stTextInput,
        input[type="text"] {
            border: 1px solid var(--input-border) !important;
            outline: none !important;
            box-shadow: none !important;
            transition: box-shadow .12s ease, border-color .12s ease !important;
            background: var(--input-bg) !important;
        }

        textarea[data-testid="stChatInputTextArea"]:focus,
        [data-testid="stChatInputTextArea"]:focus,
        .stChatInput textarea:focus,
        .stTextInput:focus,
        input[type="text"]:focus,
        textarea:focus {
            border-color: var(--focus) !important;
            box-shadow: 0 0 0 6px rgba(37,99,235,0.12) !important; /* stronger blue glow */
            outline: none !important;
        }

        /* Ensure focus-visible also uses blue and never red */
        textarea[data-testid="stChatInputTextArea"]:focus-visible,
        [data-testid="stChatInputTextArea"]:focus-visible,
        .stTextInput:focus-visible,
        input[type="text"]:focus-visible {
            border-color: var(--focus) !important;
            box-shadow: 0 0 0 6px rgba(37,99,235,0.12) !important;
            outline: none !important;
        }

        /* Neutralize any inline or framework red focus/border colors */
        [style*="#dc2626"], [style*="#b91c1c"], [style*="rgb(220, 38, 38)"], [style*="rgb(220,38,38)"] {
            border-color: transparent !important;
            box-shadow: none !important;
            outline: none !important;
        }

        /* VERY STRONG overrides for the Streamlit chat input area to remove any red border */
        div[data-testid="stChatInput"],
        div[data-testid="stChatInput"] *,
        textarea[data-testid="stChatInputTextArea"],
        textarea[data-testid="stChatInputTextArea"] * {
            border-color: var(--input-border) !important;
            box-shadow: none !important;
            outline: none !important;
            -webkit-box-shadow: none !important;
            -moz-box-shadow: none !important;
        }

        /* If any red border is applied inline to a parent, neutralize it here */
        div[data-testid="stChatInput"][style*="#dc2626"],
        div[data-testid="stChatInput"][style*="rgb(220,38,38)"],
        div[data-testid="stChatInput"] [style*="#dc2626"],
        div[data-testid="stChatInput"] [style*="rgb(220,38,38)"] {
            border-color: transparent !important;
            box-shadow: none !important;
        }

        /* Force a blue focus ring only on the textarea itself */
        textarea[data-testid="stChatInputTextArea"]:focus,
        textarea[data-testid="stChatInputTextArea"]:focus-visible {
            border-color: var(--focus) !important;
            box-shadow: 0 0 0 6px rgba(37,99,235,0.12) !important;
            outline: none !important;
        }

        /* BaseWeb / BaseUI specific classes (used by Streamlit components) */
        .baseui-input, .baseui-textarea, .baseui-input * , .baseui-textarea * {
            border-color: var(--input-border) !important;
            box-shadow: none !important;
            outline: none !important;
        }

        /* Reduce strong red color in error components but keep semantics */
        .stAlert, .stError, .st-exception { color: #b91c1c !important; }

        /* Hide Streamlit chrome when embedded */
        #MainMenu { visibility: hidden !important; }
        header { display: none !important; }
        footer { display: none !important; }
        a[href*="streamlit"] { display: none !important; }
        .css-1lsmgbg, .css-1y0tads, .css-12oz5g7 { display: none !important; }
        </style>
        """,
        unsafe_allow_html=True,
    )


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

    prompt=st.chat_input("Write your question here...")

    if prompt:
        st.chat_message('user').markdown(prompt)
        st.session_state.messages.append({'role':'user', 'content': prompt})
        # save user message to backend
        try:
            backend = os.environ.get('BACKEND_URL', 'http://localhost:5000')
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
            vectorstore=get_vectorstore()
            if vectorstore is None:
                st.error("Failed to load the vector store")

            GROQ_API_KEY=os.environ.get("GROQ_API_KEY")
            GROQ_MODEL_NAME="llama-3.1-8b-instant"

            llm= ChatGroq(
                model=GROQ_MODEL_NAME,
                temperature=0.5,
                max_tokens=512,
                api_key=GROQ_API_KEY
            )

            retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")

            combine_docs_chain= create_stuff_documents_chain(llm,retrieval_qa_chat_prompt)

            rag_chain = create_retrieval_chain(vectorstore.as_retriever(search_kwargs={'k': 3}), combine_docs_chain)
            
            response=rag_chain.invoke({'input': prompt})

            result=response["answer"]
            st.chat_message('assistant').markdown(result)
            st.session_state.messages.append({'role':'assistant', 'content': result})
          
            try:
                backend = os.environ.get('BACKEND_URL', 'http://localhost:5000')
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