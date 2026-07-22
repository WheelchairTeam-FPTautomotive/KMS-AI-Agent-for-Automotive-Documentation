# Sprint Plan — Docs-Only Version (KMS AI Agent for Automotive Documentation)

> This plan applies **only** when the committee confirms the scope is limited to
> document retrieval and citation traceability (no voice assistant, no cockpit UI).

---

## Sprint 1 — Foundation & Ingestion (Week 1)

### Minh Thuận (AI Pipeline Lead)
- [ ] Select embedding model (text-embedding-3-small vs multilingual-e5-large)
- [ ] Implement real PDF text extraction in `ingest.py` (replace stubs with PyPDF/pdfplumber)
- [ ] Define chunking strategy (size, overlap, metadata preservation)
- [ ] Initialize ChromaDB collection and verify upsert

### Thiên Ân (Backend Developer)
- [ ] Set up FastAPI project, configure CORS, mount Scalar API docs
- [ ] Define Pydantic request/response schemas with validation
- [ ] Implement `/api/v1/query` endpoint wiring to the RAG pipeline
- [ ] Add request logging middleware

### Hoàng Bảo (DevOps & Infra)
- [ ] Finalize Dockerfile and docker-compose.yml
- [ ] Test containerized startup with volume-mounted `data/` folder
- [ ] Set up `.env.example` with required environment variables
- [ ] Configure GitHub Actions CI (lint + unit tests)

### Thanh Bình (Data & Evaluation)
- [ ] Catalog all PDFs from the hackathon dataset
- [ ] Write sample test queries and expected citation matches
- [ ] Verify `mapping.json` hash codes align with ingested document IDs
- [ ] Create a test harness for `solve_problem.py`

### Minh Đức (Quality & Testing)
- [ ] Write `pytest` unit tests for safety filter and scope validation
- [ ] Test the `/health` and `/query` endpoints via `httpx`
- [ ] Document the API contract in the README
- [ ] Validate `run.sh` evaluator script produces valid JSON output

---

## Sprint 2 — RAG Accuracy & Traceability (Week 2)

### Minh Thuận
- [ ] Implement hybrid retrieval (dense vectors + BM25 keyword matching)
- [ ] Add re-ranking step (cross-encoder or MMR)
- [ ] Wire LLM call (OpenAI / Qwen / Llama) with grounding prompt
- [ ] Tune `TOP_K` and `CHUNK_SIZE` for best retrieval recall

### Thiên Ân
- [ ] Add session/history storage (SQLite or in-memory)
- [ ] Implement query deduplication and caching layer
- [ ] Add response latency tracking headers

### Hoàng Bảo
- [ ] Stress test API under concurrent load (locust / wrk)
- [ ] Optimize Docker image size (multi-stage build, slim base)
- [ ] Set up log rotation and monitoring

### Thanh Bình
- [ ] Expand test query coverage (50+ queries across all document categories)
- [ ] Build a citation accuracy evaluation script (precision/recall)
- [ ] Test abstention behavior with unsafe and out-of-scope queries

### Minh Đức
- [ ] End-to-end integration tests (ingest → query → citation validation)
- [ ] Verify citation page numbers match actual PDF content
- [ ] Document known limitations and edge cases

---

## Sprint 3 — Polish & Submission (Week 3)

### Minh Thuận
- [ ] Run official evaluation dataset through `run.sh`
- [ ] Optimize prompt template for answer quality
- [ ] Write the AI methodology section of the project report

### Thiên Ân
- [ ] Final API error handling review
- [ ] Add graceful shutdown and health probe readiness

### Hoàng Bảo
- [ ] Package submission zip (code + data + outputs)
- [ ] Verify evaluator sandbox compatibility
- [ ] Test cold-start performance

### Thanh Bình
- [ ] Compile evaluation metrics (Precision, Recall, F1, Coverage%)
- [ ] Compare results across different embedding models

### Minh Đức
- [ ] Final documentation pass on README and code comments
- [ ] Record a demo video of the query flow
- [ ] Proofread project writeup
