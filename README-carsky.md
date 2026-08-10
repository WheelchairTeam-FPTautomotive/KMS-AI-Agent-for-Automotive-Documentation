# Carsky AAOS — Connect, Tunnel & Deploy

Complete runbook for deploying `com.wheelchair.cockpit` (Wheelchair Copilot) to the Carsky cloud AAOS device over Reach ADB tunnel.

**Your machine paths (update if yours differ):**

| Item                  | Path                                                                                            |
| --------------------- | ----------------------------------------------------------------------------------------------- |
| Project root          | `H:\Project\KMS`                                                                              |
| Cockpit UI            | `H:\Project\KMS\cockpit-ui`                                                                   |
| ADB                   | `D:\Android\Sdk\platform-tools\adb.exe`                                                       |
| Reach CLI             | `C:\Users\A\Downloads\reach_be\reach\reach-backend.exe`                                       |
| Priv-app whitelist    | `H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\privapp-permissions-wheelchair.xml` |
| Debug APK             | `H:\Project\KMS\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk`                         |
| Backend tunnel script | `H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\carsky-backend-tunnel.ps1`          |
| SSH key (EC2)         | `%USERPROFILE%\.ssh\kms-ec2.pem`                                                              |

PowerShell shortcut used below:

```powershell
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
$s = "localhost:5555"
```

---

## 0. Prerequisites

1. **Backend target** (pick one):
   - **EC2 prod gateway** (recommended for demo): stack up on EIP — see `backend-orchestrator/docs/DEPLOY_EC2.md`
   - **Local laptop** orchestrator on port **8000** (and Core AI on **8001** if needed)
2. Carsky web UI open; team device **Connected**.
3. In Carsky: enable **Microphone** (browser mic) **and speaker/Audio** on the IVI / WIDE panel (playback is browser-hosted; mic-only → silent TTS).
4. Copy the live tunnel command from Carsky → device → **IVI ADB** → **Connect from Terminal** (gateway + key rotate; do not hardcode stale keys).

### Critical network fact (trout / Carsky)

The IVI guest has **no public internet egress** (`ping 8.8.8.8` / EIP → unreachable; only `10.0.2.0/24` routes, **no default gateway**). Direct app URLs like `http://52.64.18.95:8000/` **fail** even when AWS SG is `0.0.0.0/0` on `:8000` and laptop→EIP health is green.

Working path today = **laptop as middleware**:

```text
App → device 127.0.0.1:8000 → adb reverse → laptop :8000
                                    │
                    Local: uvicorn / gateway on laptop
                    Ec2:   SSH -L → EC2 gateway :8000
```

**Want direct Carsky → AWS (lower hops)?** That is a **Carsky platform** change, not Terraform/SG. Ask staff for guest egress or an allowlist to your EIP:`8000`. Then re-probe:

```powershell
powershell.exe -ExecutionPolicy Bypass -File `
  "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\carsky-probe-egress.ps1"
```

If probe prints `DIRECT WORKS` / `HTTP:200` on EIP: set Backend URL to `http://52.64.18.95:8000/` (already in NSC), skip SSH `-L`. Compare `TTFB`/`TOTAL` device→EIP vs device→`127.0.0.1` — pick the faster path for the demo.

Sample timings (session where tunnel worked, direct did not):

| Path                                | Health TOTAL (approx)                 |
| ----------------------------------- | ------------------------------------- |
| Device →`127.0.0.1` (middleware) | ~390 ms                               |
| Laptop → EIP                       | ~290 ms                               |
| Device → EIP                       | fail (`HTTP:000`, Host Unreachable) |

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

## 3. Connect the app to the backend (automated)

### 3a. One-shot script (preferred)

After Reach is up and `adb devices` shows `localhost:5555`:

```powershell
# EC2 gateway (default) — SSH -L + adb reverse + dual health checks
powershell.exe -ExecutionPolicy Bypass -File "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\carsky-backend-tunnel.ps1" -Backend Ec2

# Local laptop gateway only
powershell.exe -ExecutionPolicy Bypass -File "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\carsky-backend-tunnel.ps1" -Backend Local
```

Optional: `-Ec2Host 52.64.18.95` `-SshKey $env:USERPROFILE\.ssh\kms-ec2.pem` `-Adb D:\Android\Sdk\platform-tools\adb.exe`

Expect: laptop health **200** and device `curl` health **200**.

**Re-run after:** Reach reconnect, `adb reverse` drop, framework `stop`/`start`, or SSH forward death.

Smoke EC2 stack from laptop (no Carsky): `backend-orchestrator/scripts/smoke_ec2_stack.ps1 -BaseUrl http://52.64.18.95`

### 3b. Manual equivalent (EC2)

```powershell
# Terminal A — keep open, or use Start-Process as the script does
ssh -i $env:USERPROFILE\.ssh\kms-ec2.pem -N -L 127.0.0.1:8000:127.0.0.1:8000 ubuntu@52.64.18.95

# Terminal B
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
& $ADB connect localhost:5555
& $ADB -s localhost:5555 reverse tcp:8000 tcp:8000
curl.exe -s http://127.0.0.1:8000/api/v1/health
& $ADB -s localhost:5555 shell "curl -s -m 8 http://127.0.0.1:8000/api/v1/health"
```

### 3c. Manual equivalent (local orchestrator)

```powershell
cd H:\Project\KMS\backend-orchestrator
uv run uvicorn main:app --app-dir src --host 0.0.0.0 --port 8000 --reload

$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
& $ADB -s localhost:5555 reverse tcp:8000 tcp:8000
```

### 3d. Set Backend base URL in the app

1. Open **Wheelchair Copilot** on Carsky.
2. Open **System Settings** (Cài Đặt Hệ Thống).
3. Enable **Developer mode**.
4. Set **Backend base URL**, tap **Apply**, then **Check health**.

| Where the app runs                | Backend base URL             | Why                                                                                                   |
| --------------------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| **Carsky → EC2 or laptop** | `http://127.0.0.1:8000/`   | Hits guest loopback; reverse (+ SSH) reaches gateway                                                  |
| Direct EC2 EIP from Carsky        | `http://52.64.18.95:8000/` | **Fails** — no guest egress (CLEARTEXT still needs NSC if you test from a host that can route) |
| Local AAOS emulator only          | `http://10.0.2.2:8000/`    | Emulator host alias —**does not work on Carsky trout**                                         |

Also valid on Carsky: `http://localhost:8000/`.

Cleartext HTTP domains are allowlisted in `cockpit-ui/app/src/main/res/xml/network_security_config.xml` (`127.0.0.1`, `localhost`, `10.0.2.2`, current EIP). Rebuild after editing NSC.

### 3e. Health check success

```text
OK - 80 - ~20ms
```

| FAIL message                                 | Meaning                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------- |
| `CLEARTEXT communication … not permitted` | NSC missing host — add domain, rebuild                                     |
| `Failed to connect to /52.64.…`           | Using EIP on Carsky — switch to`127.0.0.1` + tunnel script               |
| `Failed to connect to /127.0.0.1:8000`     | No reverse / no SSH-L / gateway down — re-run`carsky-backend-tunnel.ps1` |

### Flow (mental model)

```text
App (Carsky)  →  http://127.0.0.1:8000/
      │
      ▼  adb reverse tcp:8000 tcp:8000
Reach tunnel (localhost:5555)
      │
      ▼
Laptop :8000  ──Local──►  Orchestrator on PC
              ──Ec2────►  SSH -L ──► EC2 gateway :8000
                              │
                              ▼
                         Core :8001 + VieNeu :8022 (on box)
                         Edge TTS = in-process (Microsoft cloud from EC2)
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

Wait for UI, then restore backend path:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\carsky-backend-tunnel.ps1" -Backend Ec2
```

#### 4d. Launch the app

```powershell
& $ADB -s $s shell am start -n com.wheelchair.cockpit/.MainActivity
```

On first launch, allow **Record Audio** when prompted.

---

## 5. Optional: `push_privapp.ps1`

`push_privapp.ps1` in this folder automates step 4c and restores reverse + optional EC2 tunnel via `carsky-backend-tunnel.ps1`.

```powershell
powershell.exe -ExecutionPolicy Bypass -File "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation\push_privapp.ps1"
# Local gateway instead of EC2:
powershell.exe -ExecutionPolicy Bypass -File "...\push_privapp.ps1" -Backend Local
```

---

## 6. End-to-end checklist

| # | Check                                                                              |
| - | ---------------------------------------------------------------------------------- |
| 1 | Reach tunnel terminal still listening on`127.0.0.1:5555`                         |
| 2 | `adb devices` shows `localhost:5555 device`                                    |
| 3 | `carsky-backend-tunnel.ps1 -Backend Ec2` (or Local) → dual health **200** |
| 4 | `adb reverse --list` shows `tcp:8000 tcp:8000`                                 |
| 5 | App Backend URL =`http://127.0.0.1:8000/` (not EIP, not `10.0.2.2` on Carsky)  |
| 6 | System Settings health =**OK** (green)                                       |
| 7 | Carsky browser**mic** + **Audio/speaker** enabled                      |
| 8 | App installed under`/system/priv-app/WheelchairCopilot/` (for VHAL privileges)   |
| 9 | Voice: Logcat`Backend TTS play … focus=1` + hear audio in browser/host          |

---

## 7. Troubleshooting

| Symptom                                                  | Cause                                | Fix                                                                                            |
| -------------------------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------- |
| `listen EADDRINUSE … 5555`                            | Tunnel already running / port taken  | Kill old`reach-backend`; restart one tunnel                                                  |
| `adb` not recognized                                   | Not on PATH                          | Use full path`D:\Android\Sdk\platform-tools\adb.exe`                                         |
| Carsky ADB shell`Connection closed (code 1006)`        | WebSocket drop in Carsky UI          | Ignore UI shell; use local Reach +`adb`                                                      |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE`                   | Different debug key vs installed APK | Step**4b** then **4c**                                                             |
| `DELETE_FAILED_INTERNAL_ERROR` on uninstall            | App is system priv-app               | `rm -rf /system/priv-app/WheelchairCopilot` after `root` + `remount`                     |
| Read-only filesystem on push                             | `/system` not remounted            | `adb root` → `adb remount` then push                                                      |
| Health**FAIL** / CLEARTEXT to EIP                  | Guest cannot egress / NSC            | Use`127.0.0.1` + tunnel script; rebuild if NSC changed                                       |
| Health FAIL to`127.0.0.1:8000`                         | No reverse / SSH-L / gateway down    | Re-run`carsky-backend-tunnel.ps1`                                                            |
| Device`ping 52.64…` Host Unreachable                  | Expected on trout                    | Not an AWS SG bug — use tunnel                                                                |
| Gateway log`[Edge TTS] Generated…` but no cabin sound | Carsky speaker path / browser mute   | Enable Audio on IVI/WIDE; unmute tab;`audio_vbuffer is full` = HAL writes with no host drain |
| Logcat`Backend TTS play` missing                       | Old APK                              | Rebuild / reinstall; confirm new play path                                                     |
| Voice: audio error / standby                             | Tunnel down                          | Re-run tunnel script + health OK                                                               |
| HVAC always OFF / VHAL denied                            | Lost privileged install              | Re-run**4c** with whitelist XML                                                          |
| After`push_privapp` / stop+start, API fails            | Reverse dropped                      | Re-run tunnel script                                                                           |

### Playback notes (cockpit)

- Backend returns **MP3** (`audio_base64`); cockpit plays via `MediaPlayer` with speech `AudioAttributes` + transient focus (`MainActivity.playBase64Audio`).
- Edge TTS runs **in-process on the gateway** (not a separate systemd unit). VieNeu is `:8022` fallback on EC2.
- To verify bytes independently: pull `/data/data/com.wheelchair.cockpit/cache/response_audio.mp3` and play on the PC.

---

## 8. Why priv-app (short)

AAOS gates climate/doors/speed/driving-state behind `signature|privileged`. Sideloading a normal debug APK cannot hold those grants reliably. Whitelist XML goes to `/system/etc/permissions/`; APK goes to `/system/priv-app/WheelchairCopilot/` so the package is treated as a privileged system app after framework restart (`stop` / `start`).
