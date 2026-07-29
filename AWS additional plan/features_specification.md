# 🚗 Product Feature Specification — Digital Cockpit & KMS AI Agent

This document defines the functional specifications and interface requirements for the **KMS AI Agent for Automotive Documentation** cockpit client. 

It details the **Driving Mode UI**, **Music Integration**, **AI Assistant**, and the **Concept Control Buttons** (Future Work).

---

## 1. 🚗 Driving Mode UI & Safety Logic

The dashboard HUD acts as the driver's primary interface. It dynamically responds to vehicle state changes and enforces safety boundaries.

### A. Live Map Integration
* **Behavior**: Renders a navigation map view.
* **Implementation**: Launches or embeds the native Android Map application (via intent URI `geo:0,0?q=`) or custom Map SDK fragments.

### B. Speed Telemetry (Sensor)
* **Behavior**: Real-time display of current vehicle velocity on the HUD.
* **Implementation**: Subscribes to VHAL speed property `0x11600207` (`VehiclePropertyIds.PERF_VEHICLE_SPEED`) using the Android `CarPropertyManager` API.

### C. Red Light Idle Interaction
* **Behavior**: To prevent driver distraction, media and rich interactive controls are locked while driving. When the vehicle stops at a red light, the system unlocks access.
* **Logic**:
  * **Driving State**: Speed $> 0$ km/h $\rightarrow$ **Music Button is DISABLED** (greyed out).
  * **Idle State (Red Light)**: Speed $== 0$ km/h $\rightarrow$ **Music Button is ENABLED**.

---

## 2. 🎵 Music & System Media Integration

Allows the driver to monitor and control current playback directly from the cockpit HUD dashboard.

### A. Launch Media Platform
* **Behavior**: Clicking the active **Music Button** opens the vehicle's default music application or triggers a floating overlay.
* **Implementation**: Fires a standard launcher intent (e.g., `Category.APP_MUSIC` or target package intents like Spotify/YouTube Music).

### B. System Media Session Listener
* **Behavior**: The app monitors the system's background audio output and extracts track information.
* **Implementation**: Implements `MediaSessionManager.OnActiveSessionsChangedListener` to capture the current active `MediaController`.
* **Metadata Extraction**:
  * **Song Name**: `mediaMetadata.getString(MediaMetadata.METADATA_KEY_TITLE)`
  * **Artist Name**: `mediaMetadata.getString(MediaMetadata.METADATA_KEY_ARTIST)`
  * **Album Art**: `mediaMetadata.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)`

### C. Deep-Link Routing
* **Behavior**: Clicking on the music metadata card on the HUD transitions the user immediately to the foreground interface of the corresponding music application.

---

## 3. 🤖 AI Assistant (KMS & RAG Core)

The core intelligent feature of the challenge submission.

* **Voice Query**: Triggered via the microphone button (or wake-word "Hey Car").
* **RAG Traversal**: Queries technical documentation PDF manuals.
* **Traceable Answers**: Returns the answer alongside the exact cited document name, section title, and page number, displayed as citation cards on the HUD.

---

## 4. 🎛️ Concept Demos (Future Work / Out-of-Scope)

These features represent the long-term vision of a fully integrated digital cockpit, but are kept as **Concept Dummies** to maintain focus on the core AI RAG documentation scope.

### A. ⚙️ Vehicle Control Panel Button
* **HUD Action**: Nút điều khiển chức năng xe (adjust HVAC, FM radio volume, doors, windows).
* **Behavior**: Displays a mock UI panel representing vehicle hardware configurations.
* **Demo Status**: **Concept Only**. Clicking these buttons displays a status message stating the action is *Out-of-Scope* / *Future Work*. It represents how the AI would bind to vehicle control systems in a commercial deployment.

### B. ⛐ Auto Pilot Toggle
* **HUD Action**: Nút kích hoạt chế độ tự lái (Auto Pilot).
* **Behavior**: Toggle switch on the dashboard.
* **Demo Status**: **Concept Only**. Displays a simulation notification: *"Auto Pilot feature is a future integration concept. Currently running in RAG Doc Assistant mode."*
