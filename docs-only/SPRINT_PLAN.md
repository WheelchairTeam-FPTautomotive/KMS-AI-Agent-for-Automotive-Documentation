# ⚡ Sprint Plan — Docs-Only Version (Accelerated 2-Week Timeline)

> **Scope**: Document Retrieval, Citation Traceability & Evaluation Scoring  
> **Timeline**: July 27 – August 9, 2026 (Submission before **August 10, 2026**)

---

## 📅 Sprint 1 — Ingestion, RAG Pipeline & API Setup (Week 1: July 27 – August 2)

### Minh Thuận (AI Pipeline Lead)
- [ ] Select embedding model (`text-embedding-3-small` / `multilingual-e5-large`)
- [ ] Implement PDF text parsing in `ingest.py` (PyPDF / pdfplumber)
- [ ] Define chunking rules (512 tokens / 64 overlap) preserving document hashes
- [ ] Initialize ChromaDB collection and verify upsert

### Thiên Ân (Backend Developer)
- [ ] Set up FastAPI project on port `8000`, configure CORS, mount Scalar API docs
- [ ] Define Pydantic request/response schemas with strict validation
- [ ] Wire `/api/v1/query` endpoint to RAG solver pipeline
- [ ] Add request logging and error handling middleware

### Hoàng Bảo (DevOps & Infra)
- [ ] Finalize Dockerfile (multi-stage non-root) and docker-compose.yml
- [ ] Test containerized startup with volume-mounted `data/` folder
- [ ] Set up `.env.example` with required API keys
- [ ] Configure rotating file logs

### Thanh Bình (Data & Evaluation)
- [ ] Catalog all PDFs from the hackathon dataset
- [ ] Write sample test queries and verify `mapping.json` hash codes
- [ ] Create test suite for safety filter and scope checking

### Minh Đức (Quality & Testing)
- [ ] Write `pytest` unit tests for safety filter and scope validation
- [ ] Test `/health` and `/query` endpoints via `httpx`
- [ ] Validate `run.sh` evaluator script produces valid JSON output

---

## 🚀 Sprint 2 — Accuracy, Traceability & Final Submission (Week 2: August 3 – August 9)

### Minh Thuận (AI Pipeline Lead)
- [ ] Implement hybrid retrieval (dense vectors + BM25 keyword matching)
- [ ] Build page-level citation extraction mapping document ID, section, and snippet
- [ ] Tune `TOP_K` and prompt templates for precision/recall optimization
- [ ] Run benchmark evaluator on test datasets

### Thiên Ân (Backend Developer)
- [ ] Add query caching layer and response latency tracking headers
- [ ] Implement graceful shutdown and health probe readiness

### Hoàng Bảo (DevOps & Infra)
- [ ] Execute `scripts/run.sh --input data/public --output outputs/result.json` contract verification
- [ ] Stress-test API under concurrent load and optimize cold start
- [ ] Package final submission zip for portal upload

### Thanh Bình (Data & Evaluation)
- [ ] Compile evaluation metrics (Precision, Recall, F1, Coverage%)
- [ ] Verify citation page numbers against source PDF manuals

### Minh Đức (Quality & Testing)
- [ ] End-to-end integration testing (ingest → query → citation validation)
- [ ] Record a 2-minute demo video of the query interface
- [ ] Final documentation pass on README before **August 10** submission
