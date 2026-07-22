# 📄 KMS AI Agent for Automotive Documentation (Docs-Only Version)

This is the **simplified, documentation-focused** version of the project. It strips out the Voice Assistant (STT/TTS), the Digital Cockpit (AAOS client), and the VHAL integration — leaving only a pure **RAG-based knowledge search engine** for automotive technical manuals.

> **When to use this version**: If the committee scopes the challenge to focus exclusively on document retrieval, citation traceability, and evaluation scoring — without requiring a voice interface or in-vehicle cockpit integration.

---

## Architecture Overview

```
  [ Engineer / User ]
        │
        │  HTTP POST /api/v1/query
        ▼
  ┌─────────────────────────────┐
  │   FastAPI Server (:8000)    │
  │   - Query Router            │
  │   - Health Check            │
  │   - Scalar API Docs         │
  └──────────┬──────────────────┘
             │
             ▼
  ┌─────────────────────────────┐
  │   RAG Pipeline              │
  │   - Safety & Scope Filter   │
  │   - Hybrid Retrieval        │
  │     (BM25 + Dense Vectors)  │
  │   - Grounded LLM Answer     │
  │   - Citation Mapper         │
  └──────────┬──────────────────┘
             │
             ▼
  ┌─────────────────────────────┐
  │   Vector DB (Qdrant/FAISS)  │◄── Indexed Chunks from PDFs
  └─────────────────────────────┘
```

---

## Folder Structure

```
docs-only/
├── data/                      # Place PDF manuals and corpus files here
│   └── .gitkeep
├── outputs/                   # Evaluation results written here
│   └── .gitkeep
├── src/
│   ├── main.py                # FastAPI server entrypoint (port 8000)
│   ├── api/
│   │   └── v1/
│   │       └── endpoints.py   # Query, health, and evaluation routes
│   ├── pipelines/
│   │   ├── ingest.py          # PDF parsing, chunking, and embedding
│   │   └── solve_problem.py   # RAG retrieval + LLM answer + citations
│   ├── core/
│   │   └── config.py          # Centralized settings (env vars, model params)
│   └── utils/
│       └── logger.py          # Rotating file logger
├── scripts/
│   └── run.sh                 # Evaluator contract script (--input / --output)
├── Dockerfile                 # Production container
├── docker-compose.yml         # Local dev orchestration
├── pyproject.toml             # Dependencies
└── README.md                  # This file
```

---

## Getting Started

### 1. Install Dependencies
```bash
uv sync
```

### 2. Ingest Documents
Place your PDFs in `data/` and run:
```bash
uv run python -m pipelines.ingest --source data/ --db-path .vectordb/
```

### 3. Start the API Server
```bash
uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8000 --reload
```

### 4. Query the Knowledge Base
```bash
curl -X POST http://localhost:8000/api/v1/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Làm thế nào kích hoạt phanh khẩn cấp ADAS?"}'
```

### 5. Run Offline Evaluation (Evaluator Contract)
```bash
./scripts/run.sh --input data/public --output outputs/result.json
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/health` | Service health check |
| `POST` | `/api/v1/query` | Submit a text query → receive grounded answer + citations |
| `GET` | `/docs` | Scalar interactive API reference |

---

## Team Assignments (Docs-Only Scope)

| Member | Role | Focus |
|--------|------|-------|
| **Minh Thuận** | AI Pipeline Lead | RAG pipeline accuracy, embedding model selection, prompt tuning |
| **Thiên Ân** | Backend Developer | FastAPI routes, request validation, session/history storage |
| **Hoàng Bảo** | DevOps & Infra | Docker, CI/CD, evaluator packaging, stress testing |
| **Thanh Bình** | Data & Evaluation | Document ingestion scripts, chunking strategies, test cases |
| **Minh Đức** | Quality & Testing | End-to-end query tests, citation accuracy validation, documentation |
