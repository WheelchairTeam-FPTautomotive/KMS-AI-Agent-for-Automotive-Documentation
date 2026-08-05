# 📊 Sprint 1 Progress Report: Foundation & MVP Integration

> **To**: Mentor Tuân Lê Minh  
> **From**: Team Wheelchair — FPT Hackathon 2026  
> **Date**: August 2, 2026  
> **Sprint 1 Timeline**: July 27 – August 2, 2026  
> **Sprint 1 Status**: 🟢 **100% COMPLETED**

---

## 🎯 Executive Summary
During Sprint 1, Team Wheelchair successfully scaffolded the core 3-repository microservices architecture, processed and indexed the complete set of automotive technical manuals, and established the end-to-end telemetry loop between the AAOS client, API Gateway, and local/cloud RAG search engines.

All repositories are fully integrated with **automated CI/CD pipelines** that pass testing, linting, and compile stages on GitHub Actions.

---

## 🛠️ Key Achievements by Repository

### 1. 🤖 Android Automotive Client (`cockpit-ui`)
* **Developer:** Trần Thanh Bình (UI) & Nguyễn Huỳnh Minh Đức (VHAL / Embedded)
* **Status:** 🟢 100% Completed
* **Accomplishments:**
  - **Vosk Offline STT:** Integrated local speech-to-text processing using pre-downloaded English acoustic models (`assets/model-en/`) to allow offline voice copilot functionality directly on the vehicle without network latency.
  - **Compose HUD Dashboard:** Built Jetpack Compose HUD layout showing real-time speed, seatbelt status, and AC temperature, together with citation card components.
  - **VHAL Bindings:** Integrated `CarPropertyManager` listeners for speed (`0x11600207`) and HVAC AC status (`0x15200505`).
  - **Safety Gate Integration:** Configured safety logic in `MainActivity.kt` to reject physical actions (e.g., rearview mirror folding) while driving (speed $> 0$ km/h), while permitting lookups/manual query readouts.

---

### 2. 🧠 Core AI RAG Engine (`kms-core-ai`)
* **Developer:** Nguyễn Minh Thuận (AI Pipeline) & Phạm Vũ Hoàng Bảo (Infra)
* **Status:** 🟢 100% Completed
* **Accomplishments:**
  - **Document Ingestion:** Successfully parsed and chunked **84 PDF manuals** into **5,532 vector records** stored in local ChromaDB and prepared for AWS OpenSearch Serverless.
  - **Sub-200ms Latency:** Configured fast local ONNX embeddings (`all-MiniLM-L6-v2`) running offline to meet the strict under-200ms RAG latency requirement.
  - **AWS Bedrock Integration:** Integrated Bedrock Converse API supporting Claude 3.5 Sonnet / Amazon Nova for generation, grounded strictly in retrieved document context.
  - **CI/CD Quality Control:** Implemented GitHub Actions checking `pytest`, latency SLA metrics, and syntax formatting (`ruff`). All CI checks are green.

---

### 3. 🌐 API Gateway Orchestrator (`backend-orchestrator`)
* **Developer:** Hoàng Thiên Ân (Backend) & Phạm Vũ Hoàng Bảo (DevOps)
* **Status:** 🟢 100% Completed
* **Accomplishments:**
  - **Routing & Validation:** Built HTTP proxy forwarding routing text and voice queries to the internal RAG endpoint, enforcing Pydantic request/response payload schemas.
  - **VHAL Broadcasting:** Developed `vhal_mock_sender.py` allowing manual injection of speed and HVAC states to the emulator. Fixed speed unit conversion from `km/h` to `m/s` to eliminate HUD telemetry inflation.
  - **Infrastructure as Code:** Configured standard Terraform scripts (`main.tf`, `iam.tf`) provisioning Amazon VPC, ECS Fargate cluster, and Amazon OpenSearch Serverless.
  - **Auto-Publish CD:** Configured GHA workflow to automatically compile, containerize, and push Gateway images to **GitHub Container Registry (`ghcr.io`)** on merge to `main`.

---

## 📈 Latency & Safety SLA Benchmarks

* **Core RAG Latency (Local ONNX):** **~130ms - 150ms** (Well within the 200ms SLA).
* **Core RAG Latency (AWS Bedrock):** **~450ms - 600ms** (To be optimized in Sprint 2).
* **VHAL Signal Propagation:** **< 20ms** from `vhal_mock_sender.py` broadcast to HUD layout update.
* **Safety Gate Precision:** **100%** successful rejection of mirror folding requests while driving.

---

## 🚀 Sprint 2 Preparedness & Next Steps
We have defined and ginned 3 high-priority optimization tasks to the **Wheelchair Kanban** board for Sprint 2 (August 3 – August 9) targeting extreme latency reduction:
1. **[Bảo - DevOps] Issue #12:** Provision AWS SageMaker endpoints via Terraform and configure vLLM/Triton setup with Ansible.
2. **[Thuận - AI] Issue #6:** Select lightweight Vietnamese LLMs and TTS models with zero reasoning tokens.
3. **[Ân - Backend] Issue #13:** Implement Model Context Protocol (MCP) Server/Client integration to standardize tool-calling.
