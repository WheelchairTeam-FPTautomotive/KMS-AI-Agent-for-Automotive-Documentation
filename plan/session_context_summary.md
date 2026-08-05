# 📌 Session Context Summary & Handover (July 30, 2026)

This document provides a consolidated context summary of the development state, environment settings, and upcoming Sprint tasks to minimize context consumption in future sessions.

---

## 🚗 Current Project State

### 1. VHAL Mirror Safety Check (Local/Unstaged)
* **Goal**: Block mirror folding when speed > 0 km/h, play Vietnamese TTS warning, and show a bright red HUD overlay card.
* **Code Changes**: Implemented in [MainActivity.kt](file:///H:/Project/KMS/cockpit-ui/app/src/main/java/com/wheelchair/cockpit/MainActivity.kt) and [CarPropertyHelper.kt](file:///H:/Project/KMS/cockpit-ui/app/src/main/java/com/wheelchair/cockpit/vhal/CarPropertyHelper.kt).
* **Git Status**: Changes are kept **locally unstaged** as per safety guidelines. Once approved by the PM, they should be committed and pushed:
  ```bash
  git -C H:\Project\KMS\cockpit-ui add -A
  git -C H:\Project\KMS\cockpit-ui commit -m "feat(vhal): enforce speed-sensitive mirror folding safety gate & HUD overlay warning"
  git -C H:\Project\KMS\cockpit-ui push origin main
  ```

### 2. Driver Distraction (UX Restrictions) Rules on Emulator
* **Google Play AVDs (user builds)**: Enforce strict platform signature checks. Sideloaded debug APKs (even with `distractionOptimized="true"` tags) will always trigger the *"You can't use this feature while driving"* screen when speed > 0 or Gear = D.
* **Google APIs AVDs (userdebug builds)**: Relax signature checking, allowing sideloaded debug APKs to run while driving. 
* **Action Item**: Always use **Android Automotive with Google APIs** images for active driving simulation tests. For Play Store emulators, tests must be done in parked state (Speed = 0 km/h, Gear = P).
* **Code State**: `applicationId` has been restored to `com.wheelchair.cockpit` to maintain clean package identification.

### 3. Environment & Local Servers
* **ADB**: Permanently registered in the Windows User `PATH` environment variable. Works out-of-the-box in all new terminals.
* **Backend Orchestrator**: Currently running locally at `http://0.0.0.0:8000` via:
  ```bash
  uv run uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
  ```

---

## 📅 Sprint 2 Goals & Planning Updates
The plan in [sprint_2_submission_eval.md](file:///H:/Project/KMS/KMS-AI-Agent-for-Automotive-Documentation/plan/sprint_2_submission_eval.md) has been updated and pushed:

* **Background Wake-up Capability Added**: We officially added the background hotword trigger to Sprint 2 tasks for **Trần Thanh Bình**.
* **Technical Approach**: Bình will implement a **Foreground Service** that captures audio in the background and requests `SYSTEM_ALERT_WINDOW` permission to auto-launch `MainActivity` upon detecting "Hey Car" / "Xe ơi".
