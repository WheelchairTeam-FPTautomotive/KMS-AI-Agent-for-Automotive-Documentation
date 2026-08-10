#Requires -Version 5.1
<#
.SYNOPSIS
  Wire Carsky IVI → backend: adb reverse (+ optional SSH local-forward to EC2).

.DESCRIPTION
  Trout/Carsky guests have no public internet egress. They cannot hit EC2 EIP :8000
  directly. Working path:

    App → device 127.0.0.1:8000 → adb reverse → laptop :8000
      Local:  laptop uvicorn/gateway
      Ec2:    laptop SSH -L → EC2 gateway :8000

  After this script: set Backend base URL in app to http://127.0.0.1:8000/

.PARAMETER Backend
  Local = reverse only (orchestrator already on laptop :8000)
  Ec2   = SSH -L 127.0.0.1:8000 → EC2:8000, then reverse

.EXAMPLE
  .\carsky-backend-tunnel.ps1 -Backend Ec2
  .\carsky-backend-tunnel.ps1 -Backend Local
  .\carsky-backend-tunnel.ps1 -Backend Ec2 -Ec2Host 52.64.18.95
#>
param(
    [ValidateSet("Local", "Ec2")]
    [string]$Backend = "Ec2",

    [string]$Ec2Host = "52.64.18.95",
    [string]$SshUser = "ubuntu",
    [string]$SshKey = "$env:USERPROFILE\.ssh\kms-ec2.pem",
    [string]$Adb = "C:\Users\admin\AppData\Local\Android\Sdk\platform-tools\adb.exe",
    [string]$Serial = "localhost:5555",
    [int]$Port = 8000,
    [switch]$SkipHealth
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg) { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-WarnLine([string]$msg) { Write-Host "WARN $msg" -ForegroundColor Yellow }

function Test-PortListening([int]$p) {
    $lines = netstat -ano | Select-String "LISTENING" | Select-String ":$p "
    return [bool]$lines
}

function Get-ListenerPids([int]$p) {
    $pids = @()
    netstat -ano | Select-String "LISTENING" | Select-String ":$p " | ForEach-Object {
        if ($_ -match "\s+(\d+)\s*$") { $pids += [int]$Matches[1] }
    }
    return $pids | Select-Object -Unique
}

function Connect-CarskyDevice {
    if (-not (Test-Path $Adb)) {
        throw "adb not found: $Adb (update -Adb)"
    }
    Write-Step "ADB connect $Serial"
    & $Adb connect $Serial | Out-Host
    $devsText = (& $Adb devices) -join "`n"
    if ($devsText -notmatch ([regex]::Escape($Serial) + "\s+device")) {
        throw "Device $Serial not in adb devices. Start Reach tunnel first."
    }
    Write-Ok "device $Serial attached"
}

function Start-Ec2LocalForward {
    if (-not (Test-Path $SshKey)) {
        throw "SSH key missing: $SshKey"
    }
    $ssh = "C:\Windows\System32\OpenSSH\ssh.exe"
    if (-not (Test-Path $ssh)) {
        $sshCmd = Get-Command ssh -ErrorAction SilentlyContinue
        if (-not $sshCmd) { throw "OpenSSH ssh.exe not found" }
        $ssh = $sshCmd.Source
    }

    if (Test-PortListening $Port) {
        $pids = Get-ListenerPids $Port
        Write-WarnLine "Port $Port already LISTENING (pids: $($pids -join ', ')). Reusing - skip new SSH -L."
        Write-WarnLine "If health fails, stop local uvicorn or old ssh, then re-run."
        return
    }

    Write-Step "SSH local-forward 127.0.0.1:${Port} -> ${SshUser}@${Ec2Host}:127.0.0.1:${Port}"
    $sshArgs = @(
        "-i", $SshKey,
        "-o", "StrictHostKeyChecking=accept-new",
        "-o", "ServerAliveInterval=30",
        "-o", "ServerAliveCountMax=3",
        "-o", "ExitOnForwardFailure=yes",
        "-N",
        "-L", "127.0.0.1:${Port}:127.0.0.1:${Port}",
        "${SshUser}@${Ec2Host}"
    )
    Start-Process -FilePath $ssh -ArgumentList $sshArgs -WindowStyle Hidden
    $deadline = (Get-Date).AddSeconds(12)
    while ((Get-Date) -lt $deadline) {
        if (Test-PortListening $Port) { break }
        Start-Sleep -Milliseconds 400
    }
    if (-not (Test-PortListening $Port)) {
        throw "SSH forward did not bind 127.0.0.1:$Port (check SG SSH /32, key, EC2 up)"
    }
    Write-Ok "SSH -L listening on 127.0.0.1:$Port"
}

function Set-CarskyAdbReverse {
    Write-Step "adb reverse tcp:${Port} tcp:${Port}"
    & $Adb -s $Serial reverse "tcp:${Port}" "tcp:${Port}" | Out-Host
    $list = & $Adb -s $Serial reverse --list
    Write-Host $list
    if ($list -notmatch "tcp:${Port}\s+tcp:${Port}") {
        throw "adb reverse for :$Port not active"
    }
    Write-Ok "reverse active"
}

function Invoke-GatewayHealthChecks {
    Write-Step "Health: laptop http://127.0.0.1:${Port}/api/v1/health"
    try {
        $r = curl.exe -s -m 8 -w "`nHTTP:%{http_code}" "http://127.0.0.1:${Port}/api/v1/health"
        $rText = ($r | Out-String)
        Write-Host $rText.TrimEnd()
        if ($rText -notmatch "HTTP:200") { Write-WarnLine "laptop health not 200" }
        else { Write-Ok "laptop -> gateway 200" }
    } catch {
        Write-WarnLine "laptop health failed: $_"
    }

    Write-Step "Health: device via adb shell -> 127.0.0.1:${Port}"
    $dev = & $Adb -s $Serial shell "curl -s -m 8 -w '\nHTTP:%{http_code}\n' http://127.0.0.1:${Port}/api/v1/health" 2>&1
    $devText = ($dev | Out-String)
    Write-Host $devText.TrimEnd()
    if ($devText -notmatch "HTTP:200") {
        Write-WarnLine "device health failed - re-check reverse / Reach"
    } else {
        Write-Ok "Carsky -> gateway 200"
    }
}

# --- main ---
Write-Host ""
Write-Host "Carsky backend tunnel  Backend=$Backend  Port=$Port" -ForegroundColor White
Write-Host ""

Connect-CarskyDevice

if ($Backend -eq "Ec2") {
    Start-Ec2LocalForward
} else {
    if (-not (Test-PortListening $Port)) {
        Write-WarnLine "Nothing listening on laptop :$Port - start local gateway first."
    } else {
        Write-Ok "local listener on :$Port"
    }
}

Set-CarskyAdbReverse

if (-not $SkipHealth) {
    Invoke-GatewayHealthChecks
}

Write-Host ""
Write-Host "App settings (required):" -ForegroundColor White
Write-Host "  Backend base URL = http://127.0.0.1:${Port}/"
Write-Host "  Apply -> Check health -> expect OK"
Write-Host ""
Write-Host "Do NOT use http://${Ec2Host}:${Port}/ from Carsky (no guest internet egress)." -ForegroundColor Yellow
Write-Host "Re-run this script after Reach reconnect / adb reverse drop / SSH die." -ForegroundColor Yellow
Write-Host ""
