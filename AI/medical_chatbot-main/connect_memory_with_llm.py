import os
from langchain_groq import ChatGroq
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.prompts import PromptTemplate


from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

from dotenv import load_dotenv
dotenv_path = os.path.join(os.path.dirname(__file__), ".env")
if os.path.isfile(dotenv_path):
    load_dotenv(dotenv_path)

dotenv_local_path = os.path.join(os.path.dirname(__file__), ".env.local")
if os.path.isfile(dotenv_local_path):
    load_dotenv(dotenv_local_path, override=True)

# Step 1: Setup LLM 
GROQ_API_KEY=os.environ.get("GROQ_API_KEY")
GROQ_MODEL_NAME="llama-3.1-8b-instant"

if not GROQ_API_KEY or not GROQ_API_KEY.strip():
    raise RuntimeError("Missing GROQ_API_KEY. Add it to ai/medical_chatbot-main/.env.local")


llm= ChatGroq(
    model=GROQ_MODEL_NAME,
    temperature=0.5,
    max_tokens=512,
    api_key=GROQ_API_KEY
)


# Load Database
DB_FAISS_PATH="vectorstore/db_faiss"
embedding_model=HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
db=FAISS.load_local(DB_FAISS_PATH, embedding_model, allow_dangerous_deserialization=True)

custom_prompt_template = """
Use the pieces of information provided in the context to answer user's question.
If you dont know the answer, just say that you dont know, dont try to make up an answer.
Dont provide anything out of the given context

Context: {context}
Question: {input}

Start the answer directly. No small talk please.
"""

retrieval_qa_chat_prompt = PromptTemplate(
    template=custom_prompt_template,
    input_variables=["context", "input"]
)
combine_docs_chain= create_stuff_documents_chain(llm,retrieval_qa_chat_prompt)
rag_chain = create_retrieval_chain(db.as_retriever(search_kwargs={'k': 3}), combine_docs_chain)
user_query=input("Write Query Here: ")
response=rag_chain.invoke({'input': user_query})
print("RESULT: ", response["answer"])
print("\n SOURCE DOCUMENTS: ")
for doc in response['context']:
    print(f" - {doc.metadata} -> {doc.page_content[:200]}...")