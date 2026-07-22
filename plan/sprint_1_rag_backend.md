# Sprint 1: Core RAG & Backend Gateway Setup (Week 1)

## Goal
Set up starter templates for the 3 distinct repositories: RAG Core AI (`kms-core-ai`), API Gateway (`backend-orchestrator`), and AAOS UI Client (`cockpit-ui`). Ingest documents and set up a basic text search query from the cockpit to RAG via the gateway.

## Team Roles and Task Assignments

### 1. Nguyễn Minh Thuận (Team Leader · AI Engineer Intern)
* **Role/Repo**: RAG Core AI Architect (`kms-core-ai`)
* **Tasks**:
  * Ingest the PDF manuals and corpus files from the hackathon datasets.
  * Define text chunking, overlap size, and metadata mapping schemes.
  * Initialize the internal search engine (`POST /api/v1/search` on port `8001`) with vector index lookups.

### 2. Hoàng Thiên Ân (General Application & Backend Cloud)
* **Role/Repo**: Backend Gateway Developer (`backend-orchestrator`)
* **Tasks**:
  * Initialize the FastAPI gateway server on port `8000`.
  * Create HTTP forwarding rules to route client queries to the Core AI engine (`8001`).
  * Define common Pydantic message schemas.

### 3. Phạm Vũ Hoàng Bảo (System Architecture & Linux)
* **Role/Repo**: DevOps & Simulator Developer (`backend-orchestrator`)
* **Tasks**:
  * Configure separate virtual environments (`uv`) and Docker files for the Gateway and Core AI microservices.
  * Ensure correct internal port mapping (`8000` and `8001`) and inter-container DNS resolutions.
  * Setup local logging folders.

### 4. Trần Thanh Bình (Android Automotive)
* **Role/Repo**: Android UI Developer (`cockpit-ui`)
* **Tasks**:
  * Setup Android Studio project with Automotive Jetpack Compose dependencies.
  * Create the initial cockpit HUD dashboard layout.
  * Implement query entry fields.

### 5. Nguyễn Huỳnh Minh Đức (Embedded Software Intern)
* **Role/Repo**: Embedded & AAOS VM Integration (`cockpit-ui`)
* **Tasks**:
  * Set up local ADB tunnel ports to the CarSky cockpit simulator.
  * Verify Gradle compiles stubs for `android.car` successfully.
  * Compile and deploy the initial debug APK onto the AAOS emulator.

---

## Daily Backlog & Milestones

* **Day 1-2: Microservices Scaffold**
  * Core AI & Gateway: Set up project stubs, test HTTP health endpoint connections.
  * Android: Establish ADB tunnel and verify emulator launch.
* **Day 3-4: Knowledge Indexing**
  * Core AI: Run document text chunk parser, construct local Vector DB index.
  * Gateway: Implement `/copilot/query` routing rules.
* **Day 5-6: Text QA Integration**
  * All: Query from AAOS text input -> forwards to Gateway (8000) -> forwards to Core AI (8001) -> returns answer -> UI displays result.
