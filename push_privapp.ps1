# Deploy Wheelchair Copilot to Carsky as priv-app.
# Default: APK-only (no framework stop/start — keeps ADB/tunnel up).
# Use -FullRestart only for first install or privapp XML permission changes.
param(
    [ValidateSet("Local", "Ec2")]
    [string]$Backend = "Ec2",

    # MODIFIED: skip adb shell stop/start unless explicitly requested
    [switch]$FullRestart,

    [switch]$PushPermissions
)

$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
$s = "localhost:5555"
$DocRoot = "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation"
$Apk = "H:\Project\KMS\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk"
$Tunnel = Join-Path $DocRoot "carsky-backend-tunnel.ps1"
$PermXml = Join-Path $DocRoot "privapp-permissions-wheelchair.xml"

if (-not (Test-Path $ADB)) {
    Write-Error "adb not found: $ADB"
    exit 1
}
if (-not (Test-Path $Apk)) {
    Write-Error "APK not found: $Apk - Build debug APK in Android Studio first."
    exit 1
}

& $ADB connect localhost:5555 | Out-Null
& $ADB -s $s root
& $ADB -s $s remount

# --- START MODIFICATION ---
# Permissions XML only when first-time or -PushPermissions / -FullRestart
if ($FullRestart -or $PushPermissions) {
    if (-not (Test-Path $PermXml)) {
        Write-Error "Missing permissions XML: $PermXml"
        exit 1
    }
    & $ADB -s $s push $PermXml /system/etc/permissions/
    Write-Host "Pushed privapp permissions XML."
}

& $ADB -s $s shell mkdir -p /system/priv-app/WheelchairCopilot
# MODIFIED: wipe stale ART/oat before overwrite (prevents NoSuchMethodError on Compose/Kotlin)
& $ADB -s $s shell "rm -rf /system/priv-app/WheelchairCopilot/oat /system/priv-app/WheelchairCopilot/lib"
& $ADB -s $s push $Apk /system/priv-app/WheelchairCopilot/WheelchairCopilot.apk
& $ADB -s $s shell "rm -rf /data/dalvik-cache/*/system@priv-app@WheelchairCopilot* 2>/dev/null; rm -rf /data/resource-cache/*Wheelchair* 2>/dev/null; true"

if ($FullRestart) {
    Write-Host "FullRestart: framework stop/start (ADB/tunnel may drop)..."
    & $ADB -s $s shell stop
    & $ADB -s $s shell start
    Write-Host "Waiting for framework restart..."
    Start-Sleep -Seconds 15
    & $ADB connect localhost:5555 | Out-Null
} else {
    Write-Host "Fast path: force-stop + relaunch (no OS/framework restart)."
    & $ADB -s $s shell am force-stop com.wheelchair.cockpit
    & $ADB -s $s shell am start -n com.wheelchair.cockpit/.MainActivity
}

# Restore reverse / SSH tunnel (idempotent; needed especially after FullRestart)
if (Test-Path $Tunnel) {
    & powershell.exe -ExecutionPolicy Bypass -File $Tunnel -Backend $Backend
} else {
    & $ADB -s $s reverse tcp:8000 tcp:8000
    Write-Host "Tunnel script missing; reverse 8000 only."
}
# --- END MODIFICATION ---

Write-Host "Priv-app pushed. Backend=$Backend FullRestart=$FullRestart"
Write-Host "App URL: http://127.0.0.1:8000/"
Write-Host "Launch: adb -s localhost:5555 shell am start -n com.wheelchair.cockpit/.MainActivity"
