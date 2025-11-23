import os
from langchain_groq import ChatGroq
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings


from langchain import hub
from langchain.chains.retrieval import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

from dotenv import load_dotenv
load_dotenv()

# Step 1: Setup LLM 
GROQ_API_KEY=os.environ.get("GROQ_API_KEY")
GROQ_MODEL_NAME="llama-3.1-8b-instant"


llm= ChatGroq(
    model=GROQ_MODEL_NAME,
    temperature=0.5,
    max_tokens=512,
    api_key=GROQ_API_KEY
)

# def load_llm(huggingface_repo_id):
#     llm=HuggingFaceEndpoint(
#         repo_id=huggingface_repo_id,
#         temperature=0.5,
#         model_kwargs={"token":HF_TOKEN,
#                       "max_length":"512"}
#     )
#     return llm



# Load Database
DB_FAISS_PATH="vectorstore/db_faiss"
embedding_model=HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
db=FAISS.load_local(DB_FAISS_PATH, embedding_model, allow_dangerous_deserialization=True)

retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")
combine_docs_chain= create_stuff_documents_chain(llm,retrieval_qa_chat_prompt)
rag_chain = create_retrieval_chain(db.as_retriever(search_kwargs={'k': 3}), combine_docs_chain)
user_query=input("Write Query Here: ")
response=rag_chain.invoke({'input': user_query})
print("RESULT: ", response["answer"])
print("\n SOURCE DOCUMENTS: ")
for doc in response['context']:
    print(f" - {doc.metadata} -> {doc.page_content[:200]}...")