param(
    [ValidateSet('Drive', 'Park')]
    [string]$State = 'Drive'
)

$Adb = "C:\Users\admin\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$Device = "localhost:5555"

Write-Host "Switching vehicle state to: $State" -ForegroundColor Cyan

if ($State -eq 'Drive') {
    & $Adb -s $Device shell am broadcast -a "com.wheelchair.cockpit.MOCK_DRIVE"
    Write-Host "Vehicle is now driving at 90 km/h in GEAR_DRIVE." -ForegroundColor Green
} else {
    & $Adb -s $Device shell am broadcast -a "com.wheelchair.cockpit.MOCK_PARK"
    Write-Host "Vehicle is now PARKED (0 km/h)." -ForegroundColor Green
}
