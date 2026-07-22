from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List
from pipelines.solve_problem import solve_automotive_query

router = APIRouter(prefix="/api/v1")


# ==========================================
# Request / Response Schemas
# ==========================================
class QueryRequest(BaseModel):
    query: str = Field(
        ...,
        min_length=1,
        max_length=2000,
        example="Làm thế nào kích hoạt phanh khẩn cấp ADAS?",
    )


class CitationInfo(BaseModel):
    document_id: str
    document_name: str
    section: str
    page: int
    matched_text: str


class QueryResponse(BaseModel):
    query: str
    answer: str
    citations: List[CitationInfo]
    status: str


# ==========================================
# Endpoints
# ==========================================
@router.get("/health")
async def health_check():
    """Readiness probe for the service."""
    return {"status": "ok", "service": "kms-ai-agent-docs"}


@router.post("/query", response_model=QueryResponse)
async def query_knowledge_base(payload: QueryRequest):
    """
    Main search endpoint.

    Accepts a natural-language question about automotive documentation and
    returns a grounded answer together with an array of source citations
    pointing back to specific PDF pages and sections.
    """
    try:
        result = solve_automotive_query(payload.query)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"RAG pipeline execution failed: {str(e)}",
        )
