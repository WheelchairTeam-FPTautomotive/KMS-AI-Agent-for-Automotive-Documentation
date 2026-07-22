"""
Document ingestion pipeline.

Reads PDFs from a source directory, splits them into overlapping text chunks,
generates embeddings, and stores them in a local ChromaDB vector collection.
"""

import argparse
import hashlib
import os
from typing import List, Dict, Any

from utils.logger import setup_logger

logger = setup_logger("ingest_pipeline")


def hash_file(filepath: str) -> str:
    """Compute SHA-256 hash of a file for document tracking."""
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for block in iter(lambda: f.read(8192), b""):
            sha256.update(block)
    return sha256.hexdigest()


def extract_text_from_pdf(pdf_path: str) -> List[Dict[str, Any]]:
    """
    Extract text page-by-page from a PDF.

    Returns a list of dicts: [{"page": int, "text": str}, ...]
    """
    # TODO: Replace with actual PyPDF / pdfplumber extraction
    logger.info(f"Extracting text from: {pdf_path}")
    return [
        {"page": 1, "text": f"[Stub] Extracted text from page 1 of {os.path.basename(pdf_path)}"},
        {"page": 2, "text": f"[Stub] Extracted text from page 2 of {os.path.basename(pdf_path)}"},
    ]


def chunk_text(pages: List[Dict[str, Any]], chunk_size: int = 512, overlap: int = 64) -> List[Dict[str, Any]]:
    """
    Split page texts into overlapping chunks for embedding.

    Each chunk carries its source page number for citation traceability.
    """
    chunks = []
    for page_info in pages:
        text = page_info["text"]
        page_num = page_info["page"]
        start = 0
        while start < len(text):
            end = min(start + chunk_size, len(text))
            chunks.append({
                "text": text[start:end],
                "page": page_num,
                "char_start": start,
                "char_end": end,
            })
            start += chunk_size - overlap
            if start >= len(text):
                break
    return chunks


def ingest_directory(source_dir: str, db_path: str) -> None:
    """
    Walk a directory of PDFs, extract, chunk, embed, and store in Vector DB.
    """
    logger.info(f"Ingesting documents from: {source_dir}")
    logger.info(f"Vector DB target path  : {db_path}")

    pdf_files = [
        os.path.join(source_dir, f)
        for f in os.listdir(source_dir)
        if f.lower().endswith(".pdf")
    ]

    if not pdf_files:
        logger.warning(f"No PDF files found in {source_dir}")
        return

    logger.info(f"Found {len(pdf_files)} PDF file(s) to ingest.")

    all_chunks = []
    for pdf_path in pdf_files:
        doc_hash = hash_file(pdf_path)
        doc_name = os.path.basename(pdf_path)
        logger.info(f"  Processing: {doc_name} (hash: {doc_hash[:16]}...)")

        pages = extract_text_from_pdf(pdf_path)
        chunks = chunk_text(pages)

        for chunk in chunks:
            chunk["document_id"] = doc_hash
            chunk["document_name"] = doc_name

        all_chunks.extend(chunks)

    logger.info(f"Total chunks generated: {len(all_chunks)}")

    # TODO: Generate embeddings and upsert into ChromaDB / Qdrant
    # Example:
    #   collection = chromadb.Client().get_or_create_collection(name="automotive_docs")
    #   collection.add(
    #       documents=[c["text"] for c in all_chunks],
    #       metadatas=[{k: v for k, v in c.items() if k != "text"} for c in all_chunks],
    #       ids=[f"{c['document_id']}_{c['page']}_{c['char_start']}" for c in all_chunks],
    #   )

    os.makedirs(db_path, exist_ok=True)
    logger.info(f"Ingestion complete. {len(all_chunks)} chunks ready for embedding.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest automotive PDF manuals into Vector DB")
    parser.add_argument("--source", required=True, help="Directory containing PDF files")
    parser.add_argument("--db-path", default=".vectordb/", help="Path to store the vector database")
    args = parser.parse_args()

    ingest_directory(args.source, args.db_path)
