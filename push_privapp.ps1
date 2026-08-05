$ADB = "C:/Users/admin/AppData/Local/Android/Sdk/platform-tools/adb.exe"
& $ADB -s localhost:5555 push d:\Hackathon\KMS-AI-Agent-for-Automotive-Documentation\privapp-permissions-wheelchair.xml /system/etc/permissions/
& $ADB -s localhost:5555 shell mkdir -p /system/priv-app/WheelchairCopilot
& $ADB -s localhost:5555 push d:\Hackathon\cockpit-ui\app\build\outputs\apk\debug\app-debug.apk /system/priv-app/WheelchairCopilot/WheelchairCopilot.apk
& $ADB -s localhost:5555 shell stop
& $ADB -s localhost:5555 shell start
