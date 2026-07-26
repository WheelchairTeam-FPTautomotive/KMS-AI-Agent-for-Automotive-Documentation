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

## Daily Backlog & Milestones (Individual Breakdown)

### Day 1-2 (July 27 - July 28): Environment Setup & Service Scaffolding
* **Thuận**: Initialize `kms-core-ai` project with `uv`, configure FastAPI on port `8001`, and set up text chunking stubs.
* **Ân**: Initialize `backend-orchestrator` project with `uv`, configure FastAPI gateway on port `8000`, and define Pydantic schemas.
* **Bảo**: Configure Docker multi-stage builds, set up docker-compose network between ports `8000` & `8001`, and initialize logger handlers.
* **Bình**: Setup Android Studio `cockpit-ui` project with Jetpack Compose stubs and build HUD dashboard view.
* **Đức**: Set up ADB port forwarding tunnels to CarSky simulator and verify `android.car` stubs compile cleanly.

### Day 3-4 (July 29 - July 30): PDF Ingestion & API Gateway Forwarding
* **Thuận**: Parse PDF manuals from `docs_pdf/`, generate text chunks with 512/64 overlap, and build initial ChromaDB vector collection.
* **Ân**: Build `/copilot/query` gateway endpoint forwarding requests from port `8000` to Core AI at `http://localhost:8001/api/v1/search`.
* **Bảo**: Write `vhal_mock_sender.py` signal emitter script for speed & HVAC state broadcasting.
* **Bình**: Connect Jetpack Compose Retrofit HTTP client to Gateway API (`http://10.0.2.2:8000/`) and render text response layout.
* **Đức**: Implement `CarPropertyManager` bindings for vehicle speed (`0x11600207`) and HVAC AC status (`0x15200505`).

### Day 5-7 (July 31 - August 2): End-to-End MVP Integration
* **Thuận**: Verify RAG search query returns valid grounded answers and mock citations to Gateway.
* **Ân**: Test gateway query routing under error conditions and validate payload response structures.
* **Bảo**: Test containerized service startup via Docker Compose and verify non-root user permissions.
* **Bình**: Test user query input from HUD layout and display returned RAG answer cards.
* **Đức**: Build & deploy debug APK onto CarSky AAOS emulator, verifying live telemetry updates on dashboard.
