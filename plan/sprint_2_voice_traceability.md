# Sprint 2: Voice & VHAL Integration (Week 2)

## Goal
Integrate Speech-to-Text (STT) and Text-to-Speech (TTS) routes on the Gateway orchestrator, build citation mapping (Traceability) and safety abstention filters on the AI core, and hook up VHAL signal monitoring on the AAOS Client.

## Team Roles and Task Assignments

### 1. Nguyễn Minh Thuận (Team Leader · AI Engineer Intern)
* **Role/Repo**: RAG Core AI Architect (`kms-core-ai`)
* **Tasks**:
  * Build the citation parser returning document page, section, and text matching indices.
  * Implement the safety filter (Abstention) to refuse unsafe/off-topic requests.
  * Tune dense-sparse hybrid keyword search.

### 2. Trần Thanh Bình (Android Automotive)
* **Role/Repo**: Android UI Developer (`cockpit-ui`)
* **Tasks**:
  * Implement Compose microphone recording visualizers.
  * Hook up text rendering for citation cards.
  * Add TTS playback trigger.

### 3. Hoàng Thiên Ân (General Application & Backend Cloud)
* **Role/Repo**: Backend Gateway Developer (`backend-orchestrator`)
* **Tasks**:
  * Hook up transcription (STT) calls inside the `/copilot/voice-query` gateway router.
  * Implement voice synthesis (TTS) callbacks to cache audio files.

### 4. Nguyễn Huỳnh Minh Đức (Embedded Software Intern)
* **Role/Repo**: Embedded & AAOS VM Integration (`cockpit-ui`)
* **Tasks**:
  * Write VHAL signal listeners for speed (`PERF_VEHICLE_SPEED`) and HVAC using `CarPropertyManager`.
  * Trigger UI safety overlay if vehicle speed exceeds 80 km/h.

### 5. Phạm Vũ Hoàng Bảo (System Architecture & Linux)
* **Role/Repo**: DevOps & Simulator Developer (`backend-orchestrator`)
* **Tasks**:
  * Connect simulated speech nodes (Whisper/Piper Docker images) to the gateway compose network.
  * Run the `vhal_mock_sender.py` script to broadcast fake signals and test speed callbacks in the AAOS emulator.

---

## Daily Backlog & Milestones

* **Day 1-2: Voice Pipeline**
  * Android: Build microphone audio record client.
  * Gateway: Translate uploaded audio via STT, route output query.
* **Day 3-4: Tracing & Safety**
  * Core AI: Build citation map extraction, filter out-of-scope/dangerous requests.
  * Client: Display citations dynamically.
* **Day 5-6: VHAL Integration**
  * Client: Test signal changes (changing speed values on the GPIO panel triggers cockpit speed alarms).
