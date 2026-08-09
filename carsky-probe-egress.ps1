#Requires -Version 5.1
<#
.SYNOPSIS
  Probe whether Carsky trout can reach AWS EIP directly (no laptop middleware).

.DESCRIPTION
  Today trout has only 10.0.2.0/24 routes — no default gateway — so EIP fails.
  If Carsky enables guest egress (or allowlists your EIP:8000), this script
  prints side-by-side latency: device→EIP vs device→127.0.0.1 (tunnel).

.EXAMPLE
  .\carsky-probe-egress.ps1
  .\carsky-probe-egress.ps1 -Ec2Host 52.64.18.95
#>
param(
    [string]$Ec2Host = "52.64.18.95",
    [int]$Port = 8000,
    [string]$Adb = "D:\Android\Sdk\platform-tools\adb.exe",
    [string]$Serial = "localhost:5555"
)

$ErrorActionPreference = "Continue"
$healthPath = "/api/v1/health"

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

Write-Host ""
Write-Host "Carsky egress probe  target=${Ec2Host}:${Port}" -ForegroundColor White
Write-Host ""

& $Adb connect $Serial | Out-Null
$devs = (& $Adb devices) -join "`n"
if ($devs -notmatch ([regex]::Escape($Serial) + "\s+device")) {
    throw "No device $Serial — start Reach first."
}

Write-Step "Guest routes (need a default via /0 for public AWS)"
& $Adb -s $Serial shell "ip route"

Write-Step "Ping 8.8.8.8 / EIP (ICMP may be blocked even when TCP works)"
& $Adb -s $Serial shell "ping -c 2 -W 2 8.8.8.8; ping -c 2 -W 2 $Ec2Host"

Write-Step "TCP health timings"
$curlFmt = "HTTP:%{http_code} TTFB:%{time_starttransfer} TOTAL:%{time_total}"
$eipUrl = "http://${Ec2Host}:${Port}${healthPath}"
$loopUrl = "http://127.0.0.1:${Port}${healthPath}"

Write-Host "-- device -> EIP (direct, no middleware) --"
$eip = & $Adb -s $Serial shell "curl -s -m 8 -o /dev/null -w '$curlFmt' $eipUrl" 2>&1
Write-Host ($eip | Out-String).Trim()

Write-Host "-- device -> 127.0.0.1 (adb reverse + laptop SSH/local) --"
$loop = & $Adb -s $Serial shell "curl -s -m 8 -o /dev/null -w '$curlFmt' $loopUrl" 2>&1
Write-Host ($loop | Out-String).Trim()

Write-Host "-- laptop -> EIP (your PC baseline) --"
curl.exe -s -m 8 -o NUL -w "$curlFmt`n" $eipUrl

$eipText = ($eip | Out-String)
if ($eipText -match "HTTP:200") {
    Write-Host ""
    Write-Host "DIRECT WORKS. In app Dev Settings set:" -ForegroundColor Green
    Write-Host "  http://${Ec2Host}:${Port}/"
    Write-Host "Skip carsky-backend-tunnel.ps1 -Backend Ec2 (reverse optional)."
    Write-Host "Compare TOTAL above: lower TTFB on EIP = faster than middleware."
} else {
    Write-Host ""
    Write-Host "DIRECT STILL BLOCKED (expected on stock trout)." -ForegroundColor Yellow
    Write-Host "Ask Carsky for: guest internet egress OR allowlist ${Ec2Host}:${Port}/tcp."
    Write-Host "AWS SG already open on :8000 is NOT enough without a guest default route."
    Write-Host "Keep: carsky-backend-tunnel.ps1 + http://127.0.0.1:${Port}/"
}
Write-Host ""
