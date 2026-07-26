# 🚀 Sprint 2: Traceability, Evaluation & Submission (Week 2: August 3 – August 9, 2026)

> **Timeline**: August 3 – August 9, 2026  
> **Hard Submission Deadline**: **August 10, 2026**

## Goal
Implement page-level citation traceability and safety abstention guardrails, integrate STT/TTS voice query handlers, optimize RAG retrieval precision and response latency, execute evaluator contract benchmarks (`run.sh`), record the demonstration video, and package final submissions for the committee.

---

## Team Roles & Task Assignments

### 1. Nguyễn Minh Thuận (Team Leader · AI Pipeline Architect)
* **Repo**: `kms-core-ai`
* **Tasks**:
  * Build precise citation extraction mapping page number, document hash, section title, and matched snippet.
  * Implement safety abstention filter (`check_safety_and_scope`) to decline unsafe requests ("bypass brakes") or off-topic queries.
  * Fine-tune dense + sparse (BM25) hybrid retrieval and grounded prompt templates.
  * Execute evaluation suite and benchmark precision/recall/F1 metrics.

### 2. Hoàng Thiên Ân (General Application & Backend Cloud)
* **Repo**: `backend-orchestrator`
* **Tasks**:
  * Hook up audio upload handling in `/copilot/voice-query` with STT transcription.
  * Implement TTS audio synthesis callback routing for spoken responses.
  * Add error handling, query caching, and latency tracking headers.

### 3. Phạm Vũ Hoàng Bảo (System Architecture & Linux Infrastructure)
* **Repo**: `kms-core-ai` / `backend-orchestrator`
* **Tasks**:
  * Finalize the automated evaluator contract script (`kms-core-ai/scripts/run.sh`) parsing `--input` and `--output`.
  * Package final Docker containers and verify non-root sandbox execution.
  * Perform load testing and optimize cold-start response latency (< 2.0s).

### 4. Trần Thanh Bình (Android Automotive UI Developer)
* **Repo**: `cockpit-ui`
* **Tasks**:
  * Add Compose microphone audio recording visualizer and voice query trigger.
  * Build dynamic citation card UI components with clickable source document links.
  * Implement automatic Day/Night UI theme switching following vehicle night mode property.

### 5. Nguyễn Huỳnh Minh Đức (Embedded Software & VHAL Integration)
* **Repo**: `cockpit-ui`
* **Tasks**:
  * Test driving scenario simulations using `vhal_mock_sender.py` (speed alerts > 80 km/h trigger warning banner).
  * Record 2-3 minute demonstration video showcasing voice query, citation display, and safety alerts.
  * Conduct end-to-end smoke testing prior to final zip packaging.

---

## Daily Backlog & Milestones

* **Day 1-2 (August 3-4): Citation Traceability & Voice Processing**
  * Core AI: Verify page number citations match source PDFs accurately.
  * Gateway & Android: Wire voice audio recording -> STT transcription -> RAG query -> TTS audio response.
* **Day 3-4 (August 5-6): Safety Guardrails & Evaluator Compliance**
  * Core AI: Test abstention rules against adversarial/out-of-scope prompts.
  * DevOps: Test `scripts/run.sh --input data/public --output outputs/result.json` contract execution.
* **Day 5-6 (August 7-8): Demo Recording & Final Polish**
  * Team: Record demonstration video on CarSky simulator showing full workflow.
  * Android & Gateway: Final UI style tweaks, log cleanup, and code formatting.
* **Day 7 (August 9): Package & Submit (BEFORE AUGUST 10)**
  * All: Final submission bundle verification, push code to GitHub organization, and upload submission to portal.
