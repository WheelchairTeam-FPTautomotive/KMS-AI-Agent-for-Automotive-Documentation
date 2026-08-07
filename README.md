# 🚗 KMS AI Agent for Automotive Documentation

> **Team Wheelchair** — FPT Hackathon 2026  
> An AI-powered knowledge management system that answers automotive technical questions with **traceable citations** back to source documents.

## Table of Contents

- [Important: Two Project Versions](#important-two-project-versions)
- [Team Members](#team-members)
- [Repository Structure](#repository-structure)
- [What You Should Do Right Now](#what-you-should-do-right-now)
  - [Step 1: Read the 2-Week Sprint Plans](#step-1-read-the-2-week-sprint-plans-submission-deadline-august-10)
  - [Step 2: Clone Your Working Repo](#step-2-clone-your-working-repo)
  - [Step 3: Set Up Your Environment](#step-3-set-up-your-environment)
  - [Step 4: Check the GitHub Project Board](#step-4-check-the-github-project-board)
- [Service Ports (Full Version)](#service-ports-full-version)
- [Service Ports (Docs-Only Version)](#service-ports-docs-only-version)
- [Evaluator Submission Contract](#evaluator-submission-contract)
- [Key Technical Docs](#key-technical-docs)
- [License](#license)

---

## ⚠️ Important: Two Project Versions

This repository contains **two independent project versions**. The committee may narrow the challenge scope, so we maintain both:

| Version | Folder | Description | Status |
|---------|--------|-------------|--------|
| **Full Voice Copilot** | `cockpit-ui/` + `backend-orchestrator/` + `kms-core-ai/` | 3-repo microservices with AAOS cockpit, STT/TTS voice, VHAL signals, and RAG search | Prepared |
| **Docs-Only RAG** | `docs-only/` | Single-service FastAPI RAG engine focused purely on document search & citation traceability | Prepared |

> **📌 Wait for Thuận's confirmation on which version we're going with before cloning.**  
> If the committee removes the voice assistant from scope → use `docs-only/`.  
> If they keep the full Digital Cockpit challenge → use the 3-repo split.

---

## 👥 Team Members

| Name | Role | Primary Repo(s) |
|------|------|-----------------|
| **Nguyễn Minh Thuận** | Team Leader · AI Pipeline Architect | `kms-core-ai` / `docs-only` |
| **Hoàng Thiên Ân** | Backend & Cloud Developer | `backend-orchestrator` / `docs-only` |
| **Phạm Vũ Hoàng Bảo** | System & Linux Infrastructure | `backend-orchestrator` / `docs-only` |
| **Trần Thanh Bình** | Android Automotive Developer | `cockpit-ui` / `docs-only` |
| **Nguyễn Huỳnh Minh Đức** | Embedded VHAL Software | `cockpit-ui` / `docs-only` |

---

## 📁 Repository Structure

```
KMS-AI-Agent-for-Automotive-Documentation/
│
├── 📂 docs-only/                  ← DOCS-ONLY VERSION (single repo)
│   ├── src/
│   │   ├── main.py                   FastAPI server (port 8000)
│   │   ├── api/v1/endpoints.py       Query & health routes
│   │   ├── pipelines/
│   │   │   ├── ingest.py             PDF parsing & vector DB indexing
│   │   │   └── solve_problem.py      RAG search + safety + citations
│   │   ├── core/config.py            Centralized settings
│   │   └── utils/logger.py           Rotating logger
│   ├── scripts/run.sh                Evaluator contract script
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── pyproject.toml
│   ├── SPRINT_PLAN.md                Sprint tasks for docs-only scope
│   └── README.md
│
├── 📂 cockpit-ui/                 ← FULL VERSION: Android AAOS Client (Repo 1)
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── java/com/wheelchair/cockpit/
│   │           ├── MainActivity.kt
│   │           └── CarPropertyHelper.kt
│   └── README.md
│
├── 📂 backend-orchestrator/       ← FULL VERSION: API Gateway (Repo 2)
│   ├── src/
│   │   ├── main.py
│   │   └── api/v1/gateway.py
│   ├── scripts/vhal_mock_sender.py
│   ├── pyproject.toml
│   └── README.md
│
├── 📂 kms-core-ai/                ← FULL VERSION: RAG Engine (Repo 3)
│   ├── src/
│   │   ├── main.py
│   │   ├── pipelines/solve_problem.py
│   │   └── utils/logger.py
│   ├── scripts/run.sh
│   ├── pyproject.toml
│   └── README.md
│
├── 📂 plan/                       ← 2-Week Sprint plans (Submission < August 10) & diagrams
│   ├── sprint_1_foundation_mvp.md
│   ├── sprint_2_submission_eval.md
│   ├── slide8_arch.png
│   └── slide9_resources.png
│
└── README.md                      ← This file
```

---

## 🚀 What You Should Do Right Now

### Step 1: Read the 2-Week Sprint Plans (Submission Deadline: August 10)
- **Full version** → Read [`plan/sprint_1_foundation_mvp.md`](plan/sprint_1_foundation_mvp.md) and [`plan/sprint_2_submission_eval.md`](plan/sprint_2_submission_eval.md)
- **Docs-only version** → Read [`docs-only/SPRINT_PLAN.md`](docs-only/SPRINT_PLAN.md)

### Step 2: Clone Your Working Repo
Once Thuận confirms the version, clone **only your assigned folder** into a new repository:

```bash
# Example: Thiên Ân cloning the orchestrator
git clone <new-repo-url>
cp -r backend-orchestrator/* <new-repo-dir>/
cd <new-repo-dir>
uv sync
```

### Step 3: Set Up Your Environment
**Python repos** (`backend-orchestrator`, `kms-core-ai`, `docs-only`):
```bash
# Install uv if you haven't
pip install uv

# Install dependencies
uv sync

# Copy .env.example to .env and fill in your keys
cp .env.example .env

# Start the dev server
uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8000 --reload
```

**Android repo** (`cockpit-ui`):
```bash
# Open in Android Studio
# Ensure you have AAOS system image installed
# Build → Run on Automotive emulator
```

### Step 4: Check the GitHub Project Board
All sprint tasks are tracked on the **GitHub Projects Kanban board** in our organization. Pick up your cards and move them through:
`To Do → In Progress → In Review → Done`

---

## 🔌 Service Ports (Full Version)

| Service | Port | Description |
|---------|------|-------------|
| Backend Orchestrator | `8000` | API gateway routing to speech & RAG services |
| KMS Core AI | `8001` | Internal RAG search engine |
| AAOS Emulator | `10.0.2.2` → `localhost` | Android loopback to host machine |

---

## 🔌 Service Ports (Docs-Only Version)

| Service | Port | Description |
|---------|------|-------------|
| KMS Docs API | `8000` | All-in-one RAG search server |

---

## 📋 Evaluator Submission Contract

The hackathon scoring system expects:
```bash
./scripts/run.sh --input <input_dir> --output <output_file>
```
- `--input`: Directory containing test queries
- `--output`: JSON file path for results
- The script must exit 0 on success
- Output must be valid JSON with `query`, `answer`, `citations`, and `status` fields

---

## 📚 Key Technical Docs

- [AI Edge Challenge Rules](https://hackathon-fpt.example.com/ai-edge)
- [Digital Cockpit Guidelines](https://hackathon-fpt.example.com/digital-cockpit)
- [Connected Car Dataset Info](https://hackathon-fpt.example.com/connected-car)

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.