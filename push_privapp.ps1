# MODIFIED: Paths updated for H:\Project\KMS / D:\Android\Sdk
$ADB = "D:\Android\Sdk\platform-tools\adb.exe"
$s = "localhost:5555"
$DocRoot = "H:\Project\KMS\KMS-AI-Agent-for-Automotive-Documentation"
$Apk = "H:\Project\KMS\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk"

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
& $ADB -s $s reverse tcp:8000 tcp:8000
Write-Host "Priv-app pushed. Reverse 8000 restored."
Write-Host "Launch: adb -s localhost:5555 shell am start -n com.wheelchair.cockpit/.MainActivity"
