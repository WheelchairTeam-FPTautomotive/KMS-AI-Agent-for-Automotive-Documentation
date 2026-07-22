# Sprint 3: Integration & Demo (Week 3)

## Goal
Verify RAG accuracy and response latency, run end-to-end user journeys on CarSky, compile documentation, record a demo video, and package the Core AI submission.

## Team Roles and Task Assignments

### 1. Nguyễn Minh Thuận (Team Leader · AI Engineer Intern)
* **Role/Repo**: RAG Core AI Architect (`kms-core-ai`)
* **Tasks**:
  * Execute the `evaluation.py` scoring script on the AI Core.
  * Optimize retrieval accuracy, latency, and context window sizes.
  * Write the RAG methodology section of the final writeup.

### 2. Trần Thanh Bình (Android Automotive)
* **Role/Repo**: Android UI Developer (`cockpit-ui`)
* **Tasks**:
  * Refine the cockpit HUD styling (icons, colors, typography).
  * Enable automatic Day/Night UI theme switching following the vehicle's night mode property.

### 3. Nguyễn Huỳnh Minh Đức (Embedded Software Intern)
* **Role/Repo**: Embedded & AAOS VM Integration (`cockpit-ui`)
* **Tasks**:
  * Perform end-to-end driving scenario smoke-tests.
  * Record a 2-5 minute video demonstrating voice command inputs, speed alert triggers, and citation rendering.
  * Write the Client connection section of the README.

### 4. Phạm Vũ Hoàng Bảo (System Architecture & Linux)
* **Role/Repo**: DevOps & Simulator Developer (`kms-core-ai` & `backend-orchestrator`)
* **Tasks**:
  * Implement the zipping logic in `kms-core-ai/scripts/run.sh` to package code for evaluator submission.
  * Stress-test API response latency under load.

### 5. Hoàng Thiên Ân (General Application & Backend Cloud)
* **Role/Repo**: Backend Gateway Developer (`backend-orchestrator`)
* **Tasks**:
  * Review log files and ensure correct API error handles.
  * Assist in testing final connection endpoints.

---

## Daily Backlog & Milestones

* **Day 1-2: RAG Evaluation**
  * Core AI: Run accuracy tests, optimize prompt instructions.
  * All: Conduct cross-service integration checks.
* **Day 3-4: Cockpit Demo**
  * Android: Finalize themes and HUD warning styles.
  * Team: Record backup demo video on the CarSky cockpit interface.
* **Day 5-6: Code Delivery**
  * DevOps: Test packaging scripts, verify evaluator compliance.
  * All: Submit code to GitHub, draft project writeup document.
