# Carsky AAOS — Connect, Tunnel & Deploy

Complete runbook for deploying `com.wheelchair.cockpit` (Wheelchair Copilot) to the Carsky cloud AAOS device over Reach ADB tunnel.

**Your machine paths (update if yours differ):**

| Item | Path |
|------|------|
| Project root | `H:\Project\KMS` |
| Cockpit UI | `H:\Project\KMS\cockpit-ui` |
| ADB | `D:\Android\Sdk\platform-tools\adb.exe` |
| Reach CLI | `C:\Users\A\Downloads\reach_be\reach\reach-backend.exe` |
| Priv-app whitelist | `H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\privapp-permissions-wheelchair.xml` |
| Debug APK | `H:\Project\KMS\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk` |

PowerShell shortcut used below:

```powershell
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
$s = "localhost:5555"
```

---

## 0. Prerequisites

1. Backend Orchestrator running locally on port **8000** (and Core AI on **8001** if you need RAG).
2. Carsky web UI open; team device **Connected**.
3. In Carsky: enable **Microphone** (browser mic permission).
4. Copy the live tunnel command from Carsky → device → **IVI ADB** → **Connect from Terminal** (gateway + key rotate; do not hardcode stale keys).

---

## 1. Start the Reach ADB tunnel (keep this terminal open)

```powershell
& "C:\Users\A\Downloads\reach_be\reach\reach-backend.exe" adb --gateway https://hackathon-1.carsky.io --key <PASTE_KEY_FROM_CARSKY_UI>
```

If the gateway uses a self-signed cert, append `--insecure`.

Success looks like:

- `Listening on 127.0.0.1:5555`
- `Run: adb connect localhost:5555`

**Port already in use (`EADDRINUSE … 5555`):** another Reach process (or something else) owns 5555. Kill the old `reach-backend` window/process, then start again. Do not start a second tunnel on the same port.

Leave this terminal running for the whole session.

---

## 2. Connect ADB to the tunnel

Open a **new** PowerShell:

```powershell
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
& $ADB connect localhost:5555
& $ADB devices
```

Expect: `connected to localhost:5555` and `localhost:5555 device`.

If `adb` is not on PATH, always call it via the full path above (as shown).

---

## 3. Connect the app to your local backend (tunnel → laptop `:8000`)

The car runs in Carsky cloud; Orchestrator runs on your laptop. You must (1) reverse the port over ADB, then (2) point the app at a URL that hits that reverse.

### 3a. Ensure Orchestrator is up

On the laptop:

```powershell
cd H:\Project\KMS\backend-orchestrator
uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8000 --reload
```

### 3b. ADB reverse (device → host)

```powershell
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
& $ADB connect localhost:5555
& $ADB -s localhost:5555 reverse tcp:8000 tcp:8000
```

Success prints `8000` (or confirms the reverse is already set).

Verify:

```powershell
& $ADB -s localhost:5555 reverse --list
```

Expect a line like `tcp:8000 tcp:8000`.

**Re-run reverse after every** `push_privapp` / `adb shell stop`+`start` / device restart / Reach reconnect. Reverse does not survive framework restart.

### 3c. Set Backend base URL in the app

1. Open **Wheelchair Copilot** on Carsky.
2. Open **System Settings** (Cài Đặt Hệ Thống).
3. Enable **Developer mode**.
4. Set **Backend base URL**, tap **Apply**, then **Check health**.

| Where the app runs | Backend base URL | Why |
|--------------------|------------------|-----|
| **Carsky (Reach tunnel)** | `http://127.0.0.1:8000/` | App hits the car’s localhost; `adb reverse` forwards it to your laptop `:8000` |
| Local AAOS emulator only | `http://10.0.2.2:8000/` | Emulator alias for the host PC — **does not work on Carsky** |

Also valid on Carsky: `http://localhost:8000/`.

### 3d. Health check success

You are connected when the dialog shows green, e.g.:

```text
OK - 80 - ~20ms
```

Failure like `FAIL - Failed to connect to /10.0.2.2:8000` means you are still on the emulator URL without a path that reaches the laptop — switch to `http://127.0.0.1:8000/`, confirm reverse, confirm Orchestrator is listening on `0.0.0.0:8000`.

### Flow (mental model)

```text
App (Carsky)  →  http://127.0.0.1:8000/
      │
      ▼  adb reverse tcp:8000 tcp:8000
Reach tunnel (localhost:5555)
      │
      ▼
Laptop Orchestrator  →  0.0.0.0:8000
```

---

## 4. Deploy the app

The Copilot is a **system privileged app** (`/system/priv-app/WheelchairCopilot/`). That is why normal uninstall often fails.

### When Android Studio Run is enough

Same signing key already installed as priv-app, and you only changed UI/logic (no new privileged permissions):

1. Select device `localhost:5555` in Android Studio.
2. Run / Debug.

### When you must push as priv-app

Use this when:

- Fresh / reset Carsky VM
- `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
- `adb uninstall` → `DELETE_FAILED_INTERNAL_ERROR`
- New permissions in `AndroidManifest.xml` or `privapp-permissions-wheelchair.xml`

#### 4a. Build the APK

Android Studio → **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**  
Output: `H:\Project\KMS\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk`

#### 4b. Clear the old system copy (signature lock)

```powershell
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
$s = "localhost:5555"

& $ADB -s $s root
& $ADB -s $s remount
& $ADB -s $s shell rm -rf /system/priv-app/WheelchairCopilot
& $ADB -s $s shell stop
& $ADB -s $s shell start
```

Wait 10–20s for the AAOS UI to come back. Re-connect if needed:

```powershell
& $ADB connect localhost:5555
```

#### 4c. Push whitelist + APK as priv-app

```powershell
& $ADB -s $s root
& $ADB -s $s remount

& $ADB -s $s push "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\privapp-permissions-wheelchair.xml" /system/etc/permissions/

& $ADB -s $s shell mkdir -p /system/priv-app/WheelchairCopilot
& $ADB -s $s push "H:\Project\KMS\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk" /system/priv-app/WheelchairCopilot/WheelchairCopilot.apk

& $ADB -s $s shell stop
& $ADB -s $s shell start
```

Wait for UI, then restore reverse:

```powershell
& $ADB connect localhost:5555
& $ADB -s $s reverse tcp:8000 tcp:8000
```

#### 4d. Launch the app

```powershell
& $ADB -s $s shell am start -n com.wheelchair.cockpit/.MainActivity
```

On first launch, allow **Record Audio** when prompted.

---

## 5. Optional: use / fix `push_privapp.ps1`

`push_privapp.ps1` in this folder automates step 4c, but it may still point at old `d:\Hackathon\...` and another machine’s ADB path. Edit these two lines before relying on it:

```powershell
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
# push paths → H:\Project\KMS\...
```

Then:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\push_privapp.ps1"
```

Still run `adb reverse tcp:8000 tcp:8000` afterward.

---

## 6. End-to-end checklist

| # | Check |
|---|--------|
| 1 | Reach tunnel terminal still listening on `127.0.0.1:5555` |
| 2 | `adb devices` shows `localhost:5555 device` |
| 3 | Orchestrator up on host `:8000` (`0.0.0.0`) |
| 4 | `adb reverse --list` shows `tcp:8000 tcp:8000` |
| 5 | App Backend URL = `http://127.0.0.1:8000/` (not `10.0.2.2` on Carsky) |
| 6 | System Settings health = **OK** (green) |
| 7 | Carsky browser mic enabled |
| 8 | App installed under `/system/priv-app/WheelchairCopilot/` (for VHAL privileges) |

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---------|--------|-----|
| `listen EADDRINUSE … 5555` | Tunnel already running / port taken | Kill old `reach-backend`; restart one tunnel |
| `adb` not recognized | Not on PATH | Use full path `D:\Android\Sdk\platform-tools\adb.exe` |
| Carsky ADB shell `Connection closed (code 1006)` | WebSocket drop in Carsky UI | Ignore UI shell; use local Reach + `adb` |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Different debug key vs installed APK | Step **4b** then **4c** (do not rely on Studio OK alone for priv-apps) |
| `DELETE_FAILED_INTERNAL_ERROR` on uninstall | App is system priv-app | `rm -rf /system/priv-app/WheelchairCopilot` after `root` + `remount` |
| Read-only filesystem on push | `/system` not remounted | `adb root` → `adb remount` then push |
| Health **FAIL** to `10.0.2.2:8000` on Carsky | Emulator-only host alias | Set URL to `http://127.0.0.1:8000/` + §3b reverse |
| Health FAIL to `127.0.0.1:8000` | No reverse / Orchestrator down / wrong device serial | `adb reverse --list`; start Orchestrator; use `-s localhost:5555` |
| Voice: audio error / standby | No reverse or orchestrator down | Confirm `:8000` + re-run `adb reverse` + health OK |
| HVAC always OFF / VHAL denied | Lost privileged install | Re-run **4c** with whitelist XML |
| After `push_privapp` / stop+start, API fails | Reverse dropped | `adb reverse tcp:8000 tcp:8000` again; re-check health |

---

## 8. Why priv-app (short)

AAOS gates climate/doors/speed/driving-state behind `signature\|privileged`. Sideloading a normal debug APK cannot hold those grants reliably. Whitelist XML goes to `/system/etc/permissions/`; APK goes to `/system/priv-app/WheelchairCopilot/` so the package is treated as a privileged system app after framework restart (`stop` / `start`).
