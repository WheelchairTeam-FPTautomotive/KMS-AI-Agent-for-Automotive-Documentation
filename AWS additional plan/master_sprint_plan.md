# 📋 Master Sprint Plan & Technical Specifications — Round 2

> **Project Title**: KMS AI Agent for Automotive Documentation  
> **Target Deadline**: Before August 10, 2026  
> **Team**: Nguyễn Minh Thuận (AI Lead), Hoàng Thiên Ân (Backend), Phạm Vũ Hoàng Bảo (DevOps), Trần Thanh Bình (Android UI), Nguyễn Huỳnh Minh Đức (Embedded/VHAL).

---

## 1. Combined System Architecture

This master blueprint details how the **AOSP Cockpit App**, the **AWS Cloud Backend**, and the **DevOps CI/CD Automation** are integrated:

```
                  [ Developer Commit ] ──► [ GitHub Actions ]
                                                 │ (Deploy via Ansible)
                                                 ▼
[ AOSP Cockpit Client (CarSky) ] ◄──► [ API Gateway Orchestrator (AWS Fargate) ]
  ├── Maps (geo intents)                        ├── Amazon Transcribe (STT)
  ├── VHAL Telemetry callback                   ├── AWS Bedrock: Claude 3.5 Haiku (Intent Classifier)
  ├── Red Light Music Lock                      ├── AWS Bedrock: Claude 3.5 Sonnet (RAG Engine)
  └── MediaSession Metadata                     │     └── read-only index: [ Amazon OpenSearch ]
                                                └── Amazon Polly (TTS)
```

---

## 2. Product Feature Specifications

### 🚗 Driving Mode UI & Telemetry
* **Maps Integration**: Launches native AOSP navigation map via `geo:` intents.
* **Speed Sensing**: Continuously displays vehicle speed by subscribing to VHAL property `0x11600207` (`VehiclePropertyIds.PERF_VEHICLE_SPEED`).
* **Red Light Music Lock (Driver Safety)**:
  * Speed $> 0$ km/h $\rightarrow$ Music button is disabled (locked).
  * Speed $== 0$ km/h (Red Light Idle) $\rightarrow$ Music button is enabled (unlocked).

### 🎵 System Media Integration
* **System Media Listener**: Uses `MediaSessionManager` to capture the active background playback metadata (Title, Artist, and Album art).
* **Music Card**: Displays track metadata on the HUD. Clicking the card triggers a deep-link intent routing to open the corresponding player app.

### 🎛️ Concept Control Buttons (Out of Scope / Future Work)
* **Vehicle Control (HVAC/FM)** and **Auto Pilot** buttons will exist in the UI as **dummies**.
* **Behavior**: Clicking them triggers a HUD popup warning: *"This feature is out-of-scope/future work. Current engine focuses strictly on AI KMS RAG Document Assistant."*

---

## 3. AI AWS & Intent Classification Strategy

### A. Intent Routing & Model Access (Claude 3.5 Haiku)
The API gateway acts as the router to optimize response latency and token costs under the **$456 quota**:
1. **CAR_CONTROL**: Executes speed safety checks (e.g. blocking mirror folding if speed $> 0$) and returns control logs.
2. **FREE_TALK**: Routed directly to Claude 3.5 Haiku via Bedrock for general conversation (low latency & cost).
3. **RAG_SEARCH**: Routed to Claude 3.5 Sonnet RAG engine using Amazon OpenSearch vector database.

### B. Speeched Citations (Regex Stripping)
Before sending the text response to Amazon Polly (TTS), a Python regex parser strips the bracket citations (e.g. `[0]`, `[1]`) in $0.1\text{ ms}$ at zero cost, ensuring the neural voice reads smoothly.

---

## 4. DevOps IaC & Deployment Automation

* **Terraform**: Provisions VPC networking, IAM Bedrock policies, OpenSearch Serverless collections, and ECS Fargate compute nodes.
* **Ansible**: Injects `.env` credentials, updates ECS tasks, and verifies API health checks (`GET /api/v1/health`), triggering an automated **Rollback** if the container fails to start.

---

## 📅 Consolidated 2-Week Sprint Schedule

### ⚡ Sprint 1: Foundation, Ingestion & Scaffolding (July 27 – August 2)

#### Day 1-2 (July 27 - July 28): Environment Scaffolding & Telemetry Setup (100% Completed)
* **Thuận (AI Lead)**: `[x]` Initialize `kms-core-ai` project with `uv` on port `8001` and set up text chunking stubs.
* **Ân (Backend)**: `[x]` Initialize `backend-orchestrator` project with `uv` on port `8000` and define Pydantic validation schemas.
* **Bảo (DevOps)**: `[x]` Setup directory structures for Terraform and configure ECS cluster modules (Completed `Configure Docker`).
* **Bình (Android UI)**: `[x]` Scaffold Jetpack Compose HUD layout with placeholder HUD widgets (Map, Speed, and Music cards).
* **Đức (Embedded)**: `[x]` Establish ADB port forwarding tunnels to CarSky emulator and verify `android.car` compilation stubs.

#### Day 3-4 (July 29 - July 30): OpenSearch Ingestion & Intent Classifier Setup (In Progress)
* **Thuận (AI Lead)**: `[/]` Parse PDF manuals, compute document SHA-256 hashes, and configure the Amazon OpenSearch Serverless collection (Currently in `PDF Ingestion`).
* **Ân (Backend)**: `[/]` Build the Bedrock Claude 3.5 Haiku **Intent Classifier** router (RAG vs Control vs Free Talk) inside `/copilot/query` (Ready to start).
* **Bảo (DevOps)**: `[x]` Write `vhal_mock_sender.py` to broadcast speed and HVAC status updates (Completed `Signal emitter & HVAC`).
* **Bình (Android UI)**: `[x]` Connect Retrofit HTTP client to query API (`http://10.0.2.2:8000/`) and design RAG citation result cards.
* **Đức (Embedded)**: `[/]` Implement VHAL `CarPropertyManager` listeners for speed and HVAC AC status, blocking mirror commands when speed $> 0$ (Currently in `Implement CarPropertyManager Bindings`).

#### Day 5-7 (July 31 - August 2): End-to-End MVP Integration
* **Thuận (AI Lead)**: `[ ]` Verify grounded Bedrock RAG search query returns answers and citations to the gateway.
* **Ân (Backend)**: `[ ]` Connect Amazon Transcribe (STT) and Amazon Polly (TTS) to the voice endpoint `/copilot/voice-query`.
* **Bảo (DevOps)**: `[ ]` Configure Ansible Playbooks to deploy dockerized containers and perform local health check checks.
* **Bình (Android UI)**: `[/]` Build the red-light idle logic (enable Music button only if speed $== 0$) and integrate microphone audio recording visualizers (Currently in `Validate HUD User Query Input`).
* **Đức (Embedded)**: `[ ]` Deploy the debug APK to the CarSky simulator and verify real-time telemetry updates.

---

### 🚀 Sprint 2: Traceability, Evaluation & Submission (August 3 – August 9)

#### Day 1-2 (August 3 - August 4): Citation Traceability & Media Metadata
* **Thuận (AI Lead)**: Refine page-level citation extraction and tune dense-sparse hybrid vector retrieval.
* **Ân (Backend)**: Implement Python regex citation-stripping for Polly audio output.
* **Bảo (DevOps)**: Integrate Amazon CloudWatch logging to monitor model token usages and latency metrics.
* **Bình (Android UI)**: Implement `MediaSessionManager` metadata listeners to display current song title and artist.
* **Đức (Embedded)**: Add deep-link intent routing to launch the corresponding music player when the user taps the HUD music card.

#### Day 3-4 (August 5 - August 6): Automated Evaluation & Fail-Safe Checks
* **Thuận (AI Lead)**: Build the automated evaluation suite (`evaluation.py`) calculating precision/recall metrics.
* **Ân (Backend)**: Add cache lookup layer for repeat user queries to minimize AWS Bedrock costs.
* **Bảo (DevOps)**: Implement Ansible rollback routines triggered on container startup errors and finalize `scripts/run.sh` evaluator wrapper.
* **Bình (Android UI)**: Build visual HUD warning notifications for the HVAC/Autopilot **Concept Dummy** buttons.
* **Đức (Embedded)**: Validate speed safety thresholds by injecting abnormal values via `vhal_mock_sender.py`.

#### Day 5-6 (August 7 - August 8): Demo Recording & Final Polish
* **Thuận (AI Lead)**: Analyze test results, adjust prompts, and write the RAG methodology report.
* **Ân & Bảo (Backend/DevOps)**: Perform ruff linting, code formatter checks, and optimize cold start Fargate latency.
* **Bình (Android UI)**: Optimize Compose styles, UI fonts, and enable automatic Day/Night theme toggles.
* **Đức (Embedded)**: Record a 3-minute video showing voice search, citation cards, and speed alarms on the CarSky emulator.

#### Day 7 (August 9): Package & Submit (BEFORE AUGUST 10)
* **Cả team**: Finalize project README documentation, push latest changes to team repos, create final submission zip, and upload to portal.
