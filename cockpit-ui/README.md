# Traceable Voice Copilot — Cockpit UI (Android Automotive App)

This is the Jetpack Compose Android Automotive OS (AAOS) application template for the **Traceable Voice Copilot for Digital Cockpit** project.

---

## Technical Stack
* **OS Target**: Android Automotive OS (API level 33 - Android 13+)
* **UI Framework**: Jetpack Compose (modern declarative layouts)
* **Build Tool**: Gradle Kotlin DSL (`build.gradle.kts`)
* **Libraries**: Car App Suite, Kotlin Coroutines, Retrofit/OkHttp (for API connectivity)

---

## Folder Structure
```
cockpit-ui/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/wheelchair/cockpit/
│   │       │   ├── MainActivity.kt        # Jetpack Compose UI layout
│   │       │   ├── CarPropertyHelper.kt   # VHAL subscription service
│   │       │   └── api/
│   │       │       └── CopilotClient.kt   # HTTP connection to RAG Backend
│   │       └── AndroidManifest.xml        # Permission declarations
│   └── build.gradle.kts                   # Module gradle dependencies
├── build.gradle.kts                       # Root gradle config
├── settings.gradle.kts                    # Gradle multi-module project settings
└── README.md                              # This file
```

---

## Setting up Connection to CarSky VM

To compile and debug directly on the simulated buồng lái (CarSky) device, follow these steps:

### 1. Enable Port Tunnel
1. Log in to the **CarSky Platform UI** on your browser.
2. Go to **Devices**, click **Connect** on the target AAOS virtual machine assigned to your team.
3. Open the **ADB Tunnel Widget** to retrieve the local forwarding port (for example: `5038`).

### 2. Connect via ADB
In your local command prompt or terminal, connect ADB to the forwarded port:
```bash
adb connect localhost:5038

# Verify connection
adb devices
# Output should show: localhost:5038 device
```

### 3. Run and Debug
1. Open this `cockpit-ui` project in **Android Studio**.
2. Select `localhost:5038` as the target device in the run configuration bar.
3. Click **Run** or **Debug** (Shift + F9).

---

## Communicating with Vehicle VHAL properties

The app utilizes `CarPropertyManager` to read/write real-time signals from the vehicle (e.g. speed, HVAC).

### Testing Signals Manually
You can simulate signals on the CarSky UI:
* Use the **GPIO Panel** to toggle signals (like changing speed values or switching seatbelt locks).
* Use the **Signal Watch** widget to trace values in real time.
* Verify application warnings and voice prompts react correctly to VHAL events.
