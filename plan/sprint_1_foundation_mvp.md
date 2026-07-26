# ⚡ Sprint 1: Foundation & MVP (Week 1: July 27 – August 2, 2026)

> **Timeline**: July 27 – August 2, 2026  
> **Submission Deadline**: Before August 10, 2026 (Accelerated 2-Week Plan)

## Goal
Set up the core 3-repo microservices architecture (`kms-core-ai`, `backend-orchestrator`, `cockpit-ui`), parse and ingest the automotive PDF manuals into a Vector DB, launch the RAG search endpoint, establish gateway routing, and deploy the initial AAOS Cockpit UI dashboard with VHAL signal stubs.

---

## Team Roles & Task Assignments

### 1. Nguyễn Minh Thuận (Team Leader · AI Pipeline Architect)
* **Repo**: `kms-core-ai`
* **Tasks**:
  * Parse automotive PDF manuals from `docs_pdf/` & `docs_corpus/`.
  * Implement text chunking, overlap rules (512 tokens / 64 overlap), and metadata mapping (`mapping.json`).
  * Initialize ChromaDB/Qdrant collection and build the initial vector index.
  * Expose internal RAG search query endpoint (`POST /api/v1/search` on port `8001`).

### 2. Hoàng Thiên Ân (General Application & Backend Cloud)
* **Repo**: `backend-orchestrator`
* **Tasks**:
  * Launch FastAPI Gateway API server on port `8000`.
  * Build HTTP proxy forwarding rules from Gateway (`8000`) to Core AI (`8001`).
  * Implement Pydantic request/response validation schemas for query and citation payloads.

### 3. Phạm Vũ Hoàng Bảo (System Architecture & Linux Infrastructure)
* **Repo**: `backend-orchestrator` / `kms-core-ai`
* **Tasks**:
  * Set up Docker containers and Docker Compose networking across port `8000` (Gateway) and `8001` (Core AI).
  * Configure environment variable settings (`.env`) and local rotating file logging.
  * Prepare VHAL simulation script (`vhal_mock_sender.py`) for vehicle signal testing.

### 4. Trần Thanh Bình (Android Automotive UI Developer)
* **Repo**: `cockpit-ui`
* **Tasks**:
  * Initialize Jetpack Compose AAOS application targeting Android 13+ (API 33).
  * Build HUD dashboard UI layout with speed indicators, HVAC status, and search query panel.
  * Connect Jetpack Compose Retrofit client to the Gateway API (`http://10.0.2.2:8000/`).

### 5. Nguyễn Huỳnh Minh Đức (Embedded Software & VHAL Integration)
* **Repo**: `cockpit-ui`
* **Tasks**:
  * Set up local ADB port forwarding tunnels to the CarSky cockpit simulator.
  * Implement `CarPropertyManager` bindings for vehicle speed (`0x11600207`) and HVAC AC status (`0x15200505`).
  * Verify AAOS APK builds cleanly and deploys onto the emulator.

---

## Daily Backlog & Milestones

* **Day 1-2 (July 27-28): Microservices & Environment Setup**
  * Core AI & Gateway: Set up Python environments (`uv`), verify FastAPI startup on ports `8000` & `8001`.
  * Cockpit UI: Build Jetpack Compose UI layout, test ADB tunnel to CarSky simulator.
* **Day 3-4 (July 29-30): Ingestion & Vector Indexing**
  * Core AI: Run PDF text extraction, chunking, and ChromaDB collection indexing.
  * Gateway: Connect `/copilot/query` route to forward requests to `localhost:8001`.
* **Day 5-7 (July 31 - August 2): End-to-End MVP Integration**
  * All: Verify full loop: User types query on AAOS Cockpit → Gateway (`8000`) → Core AI (`8001`) → Returns answer & citations → Rendered on HUD.
