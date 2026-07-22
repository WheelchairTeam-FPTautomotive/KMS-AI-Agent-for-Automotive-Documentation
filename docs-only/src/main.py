from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.v1.endpoints import router as api_router
from core.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    description=(
        "RAG-powered search engine for automotive technical documentation. "
        "Accepts natural-language queries and returns grounded answers with "
        "traceable citations back to source PDF pages and sections."
    ),
    version=settings.APP_VERSION,
)

# CORS — allow broad access during hackathon development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API routes
app.include_router(api_router)


@app.on_event("startup")
async def on_startup():
    print(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} is running on port 8000")
    print(f"   Vector DB path : {settings.VECTOR_DB_PATH}")
    print(f"   Embedding model: {settings.EMBEDDING_MODEL}")
    print(f"   LLM model      : {settings.LLM_MODEL}")
    print(f"   Top-K retrieval : {settings.TOP_K}")
