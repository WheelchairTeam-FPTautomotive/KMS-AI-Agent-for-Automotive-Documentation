# KMS AI Agent — Core AI RAG Engine (Repo 3)

This is the Core AI RAG (Retrieval-Augmented Generation) Engine for the **Traceable Voice Copilot** project. It is managed by **Nguyễn Minh Thuận (AI Lead)** and is responsible for ingesting manuals, managing vector indices, and serving grounded search answers.

---

## Technical Stack
* **Language**: Python 3.12+
* **Package Manager**: `uv`
* **Framework**: FastAPI (exposes internal REST interface on port `8001`)
* **Core Libraries**: OpenAI, ChromaDB, LlamaIndex/LangChain, PyPDF, pytest

---

## Folder Structure
```
kms-core-ai/
├── data/                  # Ingested PDF and Text corpus
├── outputs/               # Solution output json/csv artifacts
├── src/
│   ├── main.py            # API server entrypoint (port 8001)
│   ├── pipelines/
│   │   └── solve_problem.py # Retrieval, safety checks & citation mapping
│   └── utils/
│       └── logger.py      # Console and log rotation
├── scripts/
│   └── run.sh             # Evaluator contract bash wrapper
├── pyproject.toml         # Dependency Definitions
└── README.md              # This file
```

---

## Getting Started

### 1. Install Dependencies
```bash
# In this folder
uv sync
```

### 2. Run the Core AI Search Server
```bash
uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8001 --reload
```

---

## Core Operations

### RAG Search Query (`POST /api/v1/search`)
Receives query text, checks safety/abstention, executes hybrid vector + keyword lookup, queries LLM, maps page citations, and returns:
```json
{
  "query": "Query text here",
  "answer": "Grounded answer text",
  "citations": [
    {
      "document_id": "...",
      "document_name": "...",
      "section": "...",
      "page": 12,
      "matched_text": "..."
    }
  ],
  "status": "success"
}
```

### Evaluator Contract (`scripts/run.sh`)
Required script for the automated hackathon scoring system. Evaluates the practice/private test datasets in offline batch mode:
```bash
./scripts/run.sh --input data/public --output outputs/result.json
```
