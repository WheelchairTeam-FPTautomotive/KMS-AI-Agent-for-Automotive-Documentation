# MODIFIED: Paths for H:\Project\KMS; restore backend tunnel after framework restart
param(
    [ValidateSet("Local", "Ec2")]
    [string]$Backend = "Ec2"
)

$ADB = "C:\Users\admin\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$s = "localhost:5555"
$DocRoot = "d:\Hackathon\KMS-AI-Agent-for-Automotive-Documentation"
$Apk = "d:\Hackathon\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk"
$Tunnel = Join-Path $DocRoot "carsky-backend-tunnel.ps1"

if (-not (Test-Path $Apk)) {
    Write-Error "APK not found: $Apk - Build APK(s) in Android Studio first."
    exit 1
}

& $ADB connect localhost:5555 | Out-Null
& $ADB -s $s root
& $ADB -s $s remount

& $ADB -s $s push "$DocRoot\privapp-permissions-wheelchair.xml" /system/etc/permissions/
& $ADB -s $s shell mkdir -p /system/priv-app/WheelchairCopilot
& $ADB -s $s push $Apk /system/priv-app/WheelchairCopilot/WheelchairCopilot.apk

& $ADB -s $s shell stop
& $ADB -s $s shell start

Write-Host "Waiting for framework restart..."
Start-Sleep -Seconds 15

& $ADB connect localhost:5555 | Out-Null

# --- START MODIFICATION ---
# Reverse alone is not enough for EC2: also SSH -L via carsky-backend-tunnel.ps1
if (Test-Path $Tunnel) {
    & powershell.exe -ExecutionPolicy Bypass -File $Tunnel -Backend $Backend
} else {
    & $ADB -s $s reverse tcp:8000 tcp:8000
    Write-Host "Tunnel script missing; reverse 8000 only."
}
# --- END MODIFICATION ---

Write-Host "Priv-app pushed. Backend=$Backend tunnel restored."
Write-Host "App URL: http://127.0.0.1:8000/"
Write-Host "Launch: adb -s localhost:5555 shell am start -n com.wheelchair.cockpit/.MainActivity"
