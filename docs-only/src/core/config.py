import os
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Centralized configuration loaded from environment variables."""

    # Server
    APP_NAME: str = "KMS AI Agent for Automotive Documentation"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False

    # Vector DB
    VECTOR_DB_PATH: str = ".vectordb/"
    COLLECTION_NAME: str = "automotive_docs"

    # Embedding & LLM
    EMBEDDING_MODEL: str = "text-embedding-3-small"
    LLM_MODEL: str = "gpt-4o-mini"
    OPENAI_API_KEY: Optional[str] = None

    # Chunking
    CHUNK_SIZE: int = 512
    CHUNK_OVERLAP: int = 64

    # Retrieval
    TOP_K: int = 5

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
