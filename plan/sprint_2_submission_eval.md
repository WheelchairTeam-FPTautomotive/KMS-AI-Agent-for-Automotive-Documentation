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
  * Implement background wake-word listener service ("Hey Car") using Foreground Service and `SYSTEM_ALERT_WINDOW` permission to automatically launch/bring the app to foreground when closed or in background.
  * Build dynamic citation card UI components with clickable source document links.
  * Implement automatic Day/Night UI theme switching following vehicle night mode property.

### 5. Nguyễn Huỳnh Minh Đức (Embedded Software & VHAL Integration)
* **Repo**: `cockpit-ui`
* **Tasks**:
  * Test driving scenario simulations using `vhal_mock_sender.py` (speed alerts > 80 km/h trigger warning banner).
  * Record 2-3 minute demonstration video showcasing voice query, citation display, and safety alerts.
  * Conduct end-to-end smoke testing prior to final zip packaging.

---

## Daily Backlog & Milestones (Individual Breakdown)

### Day 1-2 (August 3 - August 4): Citation Traceability & Voice Processing
* **Thuận**: Implement page-level citation extraction mapping document ID, section name, page number, and matched snippet text.
* **Ân**: Implement STT transcription handler in `/copilot/voice-query` and configure TTS audio synthesis response routing.
* **Bảo**: Connect Whisper / TTS sidecar containers and benchmark API gateway latency (< 2.0s).
* **Bình**: Build Compose mic audio recording UI component, citation display cards, and implement the background "Hey Car" wake-word Foreground Service (with `SYSTEM_ALERT_WINDOW` permission for auto-launch).
* **Đức**: Test voice query flow from AAOS emulator mic input to gateway response playback.

### Day 3-4 (August 5 - August 6): Safety Guardrails & Evaluator Compliance
* **Thuận**: Implement safety abstention filter (`check_safety_and_scope`) blocking unsafe ("bypass brakes") or off-topic queries.
* **Ân**: Add response query caching and error handling fallback responses.
* **Bảo**: Finalize automated evaluator contract script (`kms-core-ai/scripts/run.sh`) and verify `--input` / `--output` execution.
* **Bình**: Add speed warning alert banner UI overlay triggered when vehicle speed > 80 km/h.
* **Đức**: Run simulated driving scenarios via `vhal_mock_sender.py` to verify speed alert triggers in AAOS HUD.

### Day 5-6 (August 7 - August 8): Demo Video & Final Polish
* **Thuận**: Execute evaluation suite, calculate precision/recall/F1 metrics, and write AI methodology report.
* **Ân**: Perform final API gateway log review and code formatting (`ruff`).
* **Bảo**: Verify Docker container cold-start performance and sandbox compliance.
* **Bình**: Finalize Compose HUD styling, typography, and automatic Day/Night theme switching.
* **Đức**: Record 2-3 minute demonstration video showing voice input, citation cards, and speed warning alerts on CarSky.

### Day 7 (August 9): Final Packaging & Portal Submission (BEFORE AUGUST 10)
* **Thuận & Ân**: Conduct final query accuracy sanity check across all benchmark datasets.
* **Bảo**: Build final submission zip package (source code + data + evaluation outputs).
* **Bình & Đức**: Verify project README documentation links and upload video demo link.
* **All (Thuận, Ân, Bảo, Bình, Đức)**: Final git push to repository and submit package on FPT Hackathon portal before August 10.
