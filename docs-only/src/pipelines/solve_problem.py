"""
RAG solve pipeline.

Performs safety validation, hybrid retrieval (dense + sparse), grounded LLM
answer generation, and citation mapping back to source PDF pages.
"""

import json
import os
from typing import Any, Dict, List, Tuple

from utils.logger import setup_logger

logger = setup_logger("rag_pipeline")

# ==========================================
# Safety & Scope Filters
# ==========================================
UNSAFE_TRIGGERS = [
    "hack",
    "bypass brakes",
    "overdrive engine safety",
    "ignore seatbelt alert",
    "disable airbag",
    "remove speed limiter",
]

AUTOMOTIVE_KEYWORDS = [
    "car", "vehicle", "engine", "brake", "sensor", "battery",
    "hvac", "seatbelt", "adas", "cluster", "dashboard", "manual",
    "tài liệu", "hướng dẫn", "xe", "phanh", "động cơ", "cảm biến",
    "điều hòa", "buồng lái", "hệ thống", "an toàn",
]


def check_safety_and_scope(query: str) -> Tuple[bool, str]:
    """
    Validate that a query is safe and within the automotive documentation scope.

    Returns:
        (is_valid, refusal_reason) — if is_valid is False, refusal_reason
        contains a localized explanation.
    """
    query_lower = query.lower()

    for trigger in UNSAFE_TRIGGERS:
        if trigger in query_lower:
            logger.warning(f"Unsafe request blocked: '{query}' matched trigger: '{trigger}'")
            return False, "Yêu cầu bị từ chối vì lý do an toàn vận hành xe."

    is_on_topic = any(kw in query_lower for kw in AUTOMOTIVE_KEYWORDS)
    if not is_on_topic:
        logger.warning(f"Out-of-scope request: '{query}'")
        return False, (
            "Tôi chỉ hỗ trợ giải đáp các câu hỏi liên quan đến "
            "vận hành và hướng dẫn kỹ thuật của xe."
        )

    return True, ""


# ==========================================
# Core RAG Pipeline
# ==========================================
def solve_automotive_query(query: str) -> Dict[str, Any]:
    """
    Full RAG pipeline execution:

    1. Safety & scope validation
    2. Vector similarity search (hybrid dense+sparse)
    3. Re-rank retrieved chunks
    4. LLM grounded answer generation
    5. Citation metadata extraction
    """
    logger.info(f"Processing query: '{query}'")

    # Step 1: Safety gate
    is_valid, refusal_reason = check_safety_and_scope(query)
    if not is_valid:
        return {
            "query": query,
            "answer": refusal_reason,
            "citations": [],
            "status": "refused",
        }

    # Step 2–3: Retrieve top-k chunks from vector DB
    # TODO: Replace stubs with actual ChromaDB / Qdrant queries
    logger.info("Executing vector search...")
    retrieved_chunks = [
        {
            "document_id": "949eb66893b5dbf59aa4b4be35ad330c7b8f0c3802f9ccb8d25881128157bf9c",
            "document_name": "2011 - KMS Manual.pdf",
            "section": "Chương 4: Điều hòa & Hệ thống điện",
            "page": 42,
            "matched_text": (
                "Hệ thống điều hòa (HVAC) được điều khiển qua "
                "CarPropertyManager với AreaId là 0."
            ),
        },
        {
            "document_id": "1ecc7f4e2b438cb0ac5c336fed7cfffbca78b42f87a31a0c0add50aa38cfc751",
            "document_name": "light-control-system.pdf",
            "section": "Chương 7: ADAS & Phanh khẩn cấp",
            "page": 105,
            "matched_text": (
                "Khi xe chạy quá tốc độ 80km/h, hệ thống ADAS kích hoạt "
                "phanh khẩn cấp tự động (AEB) nếu khoảng cách xe trước < 15m."
            ),
        },
    ]

    # Step 4: Generate grounded answer via LLM
    # TODO: Replace with actual OpenAI / Qwen / Llama call
    answer = (
        "Dựa trên tài liệu hướng dẫn kỹ thuật của xe:\n"
        "1. Hệ thống điều hòa (HVAC) hoạt động trên VHAL thông qua "
        "CarPropertyManager (AreaId: 0).\n"
        "2. Phanh khẩn cấp tự động (AEB) hoạt động kết hợp với ADAS sẽ "
        "kích hoạt để bảo vệ an toàn khi xe chạy > 80km/h và khoảng cách "
        "va chạm dưới 15m."
    )

    # Step 5: Format citations
    citations = [
        {
            "document_id": c["document_id"],
            "document_name": c["document_name"],
            "section": c["section"],
            "page": c["page"],
            "matched_text": c["matched_text"],
        }
        for c in retrieved_chunks
    ]

    logger.info(f"Generated answer with {len(citations)} citation(s).")
    return {
        "query": query,
        "answer": answer,
        "citations": citations,
        "status": "success",
    }


# ==========================================
# Offline Batch Evaluator CLI
# ==========================================
if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="KMS RAG Offline Evaluator — batch process queries"
    )
    parser.add_argument("--input", required=True, help="Input directory containing query files")
    parser.add_argument("--output", required=True, help="Output JSON file path for results")
    args = parser.parse_args()

    logger.info(f"Offline evaluation: input={args.input}, output={args.output}")

    # TODO: Read actual query files from --input directory
    queries = ["Làm thế nào kích hoạt phanh khẩn cấp ADAS?"]

    results = []
    for q in queries:
        res = solve_automotive_query(q)
        results.append(res)

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    logger.info(f"Evaluation complete. {len(results)} result(s) written to: {args.output}")
