# ⚡ AWS Transition & Development Plan — Round 2

> **Project Title**: KMS AI Agent for Automotive Documentation  
> **Submission Deadline**: Before August 10, 2026  
> **Infrastructure Update**: Switched from local hosting to fully-resourced **AWS Cloud Services** (Bedrock, Transcribe, Polly, OpenSearch).

---

## 1. Target AWS Cloud Architecture

Instead of running heavy inference locally on AOSP/Edge devices, the system will delegate processing to low-latency AWS services:

```
[ AOSP Cockpit Client ] 
       │ (1) User Voice/Text Query (FastAPI: Port 8000)
       ▼
[ API Gateway Orchestrator ] 
       ├── (2) Audio to Text ──────────► [ Amazon Transcribe ]
       ├── (3) Identify Intent ────────► [ AWS Bedrock: Claude 3.5 Haiku ]
       │                                     ├── CAR_CONTROL -> Check VHAL Speed & Exec
       │                                     ├── FREE_TALK   -> AWS Bedrock chat response
       │                                     └── RAG_SEARCH  -> Query Vector Index
       │                                                            │
       │                                                            ▼
       │                                                   [ Amazon OpenSearch ]
       │                                                            │ (Retrieve Chunks)
       │                                                            ▼
       │                                                [ AWS Bedrock: Claude 3.5 Sonnet ]
       │                                                                  (Synthesis + Citations)
       └── (4) Text to Speech ─────────► [ Amazon Polly ]
```

---

## 2. Sprint 1: AWS Foundation, Ingestion & Intent Classifier (July 27 – August 2)

### 👥 Individual Tasks & Assignees

#### 1. Nguyễn Minh Thuận (AI Lead) — `kms-core-ai`
- [ ] Set up **Amazon OpenSearch Serverless** vector collection.
- [ ] Implement text chunking (512 tokens / 64 overlap) and ingest PDFs using `boto3`.
- [ ] Configure **AWS Bedrock (Claude 3.5 Sonnet)** system prompts to enforce strict grounding and page citations.
- [ ] Expose internal RAG endpoint `POST /api/v1/search` on port `8001`.

#### 2. Hoàng Thiên Ân (Backend Dev) — `backend-orchestrator`
- [ ] Configure `boto3` wrappers for **Amazon Transcribe** (STT) and **Amazon Polly** (TTS).
- [ ] Implement the **Intent Classifier** router (using Claude 3.5 Haiku on Bedrock) to categorize inputs into:
  1. `CAR_CONTROL`
  2. `RAG_SEARCH`
  3. `FREE_TALK`
- [ ] Set up `/copilot/query` and `/copilot/voice-query` gateway endpoints.

#### 3. Phạm Vũ Hoàng Bảo (DevOps) — `backend-orchestrator` / `kms-core-ai`
- [ ] Set up Dockerfiles and `docker-compose.yml` configured with AWS credential environment variables.
- [ ] Set up a mock VHAL signal sender (`vhal_mock_sender.py`) simulating speed & HVAC triggers.
- [ ] Configure API logging to track latency metrics (STT duration, LLM duration, RAG query duration, Polly duration).

#### 4. Trần Thanh Bình (Android UI) — `cockpit-ui`
- [ ] Scaffolding Jetpack Compose dashboard HUD layouts with Telemetry indicators.
- [ ] Implement query text input and Compose audio recording visualizer.
- [ ] Integrate citation card UI rendering with clickable source links.

#### 5. Nguyễn Huỳnh Minh Đức (Embedded/VHAL) — `cockpit-ui`
- [ ] Maintain ADB tunnels to CarSky emulator.
- [ ] Bind `CarPropertyManager` listeners for speed and HVAC AC status.
- [ ] Implement client-side safety guard (e.g. if speed $> 0$ km/h, block physical mirror controls and display safety HUD alert).

---

## 3. Sprint 2: Test Matrix, Latency Tuning & Submission (August 3 – August 9)

- **Automated Test Matrix**:
  * Execute 150+ queries (50 per intent class) to measure Intent Classification accuracy, RAG page citation correctness, and response latency.
- **Latency Target**:
  * Car Control response < 1.0s.
  * RAG search response < 300ms.
- **Deliverables Prep**:
  * Record 2-3 minute demo video on CarSky simulator showcasing Voice assistant, citations, and VHAL safety warning alerts.
  * Package final repository zip for FPT Hackathon portal submission before **August 10**.
