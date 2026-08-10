# MODIFIED: ABI-aware YouTube Music + SoundCloud (APKM) install + MP3 push/scan
# Usage:
#   powershell.exe -ExecutionPolicy Bypass -File install-media-stack.ps1
#   powershell.exe -ExecutionPolicy Bypass -File install-media-stack.ps1 -Serial emulator-5554
#   powershell.exe -ExecutionPolicy Bypass -File install-media-stack.ps1 -MediaDir "C:\Users\A\Downloads\media" -SkipLaunch
param(
    [string]$Serial = "localhost:5555",
    [string]$MediaDir = "C:\Users\A\Downloads\media",
    [string]$AdbPath = "D:\Android\Sdk\platform-tools\adb.exe",
    [string]$RemoteMusicDir = "/sdcard/Music/Wheelchair",
    [switch]$SkipApkInstall,
    [switch]$SkipMp3,
    [switch]$SkipLaunch
)

$ErrorActionPreference = "Stop"

function Resolve-Adb {
    param([string]$Preferred)
    if ($Preferred -and (Test-Path $Preferred)) { return $Preferred }
    $fromPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($fromPath) { return $fromPath.Source }
    throw "adb not found. Set -AdbPath or add platform-tools to PATH."
}

function Invoke-Adb {
    param([Parameter(Mandatory = $true)][string[]]$AdbArgs)
    # IMPORTANT: pass as string[] so PowerShell does not eat flags like -p / -g
    & $script:ADB -s $script:Serial @AdbArgs
    if ($LASTEXITCODE -ne 0) {
        throw "adb failed ($LASTEXITCODE): adb -s $script:Serial $($AdbArgs -join ' ')"
    }
}

function Try-Adb {
    param([Parameter(Mandatory = $true)][string[]]$AdbArgs)
    # Swallow stdout so callers get only the exit code (not adb log lines).
    & $script:ADB -s $script:Serial @AdbArgs 1>$null 2>$null
    return $LASTEXITCODE
}

function Get-DeviceAbi {
    $abi = (& $script:ADB -s $script:Serial shell getprop ro.product.cpu.abi).Trim()
    if (-not $abi) { throw "Could not read ro.product.cpu.abi" }
    return $abi
}

function Select-YouTubeMusicApk {
    param([string]$Dir, [string]$Abi)
    $apks = Get-ChildItem -Path $Dir -Filter "com.google.android.apps.youtube.music*.apk" -ErrorAction SilentlyContinue
    if (-not $apks) { throw "No YouTube Music APK found in $Dir" }

    $arm = $apks | Where-Object { $_.Name -match "arm64-v8a" } | Select-Object -First 1
    $x86 = $apks | Where-Object { $_.Name -match "x86_64" } | Select-Object -First 1

    if ($Abi -match "arm64") {
        if (-not $arm) { throw "Device ABI=$Abi but no arm64-v8a YouTube Music APK in $Dir" }
        return $arm
    }
    if ($Abi -match "x86") {
        if (-not $x86) { throw "Device ABI=$Abi but no x86_64 YouTube Music APK in $Dir" }
        return $x86
    }
    # Fallback: prefer arm64 package if present
    if ($arm) { return $arm }
    return ($apks | Select-Object -First 1)
}

function Select-SoundCloudApkm {
    param([string]$Dir, [string]$Abi)
    $apkms = @(Get-ChildItem -Path $Dir -Filter "com.soundcloud.android*.apkm" -ErrorAction SilentlyContinue)
    if (-not $apkms) {
        # Plain APK fallback if user converted bundles
        $plain = Get-ChildItem -Path $Dir -Filter "com.soundcloud.android*.apk" -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($plain) { return @{ Kind = "apk"; File = $plain } }
        throw "No SoundCloud .apkm/.apk found in $Dir"
    }

    # Prefer smallest bundle that still contains the device ABI split.
    $ranked = $apkms | Sort-Object Length
    foreach ($candidate in $ranked) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
        $zip = [System.IO.Compression.ZipFile]::OpenRead($candidate.FullName)
        try {
            $names = $zip.Entries | ForEach-Object { $_.FullName }
            $hasArm64 = $names -contains "split_config.arm64_v8a.apk"
            $hasX64 = $names -contains "split_config.x86_64.apk"
            if ($Abi -match "arm64" -and $hasArm64) {
                return @{ Kind = "apkm"; File = $candidate }
            }
            if ($Abi -match "x86" -and $hasX64) {
                return @{ Kind = "apkm"; File = $candidate }
            }
        } finally {
            $zip.Dispose()
        }
    }
    # Last resort: largest (4arch) bundle
    return @{ Kind = "apkm"; File = ($apkms | Sort-Object Length -Descending | Select-Object -First 1) }
}

function Install-SoundCloudApkm {
    param([System.IO.FileInfo]$Apkm, [string]$Abi)

    $work = Join-Path $env:TEMP ("sc-apkm-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($Apkm.FullName, $work)

        $base = Join-Path $work "base.apk"
        if (-not (Test-Path $base)) { throw "APKM missing base.apk: $($Apkm.Name)" }

        $splits = @($base)
        $wanted = @()
        if ($Abi -match "arm64") {
            $wanted += "split_config.arm64_v8a.apk"
            # Some builds also need armeabi_v7a; include if present
            $wanted += "split_config.armeabi_v7a.apk"
        } elseif ($Abi -match "x86") {
            $wanted += "split_config.x86_64.apk"
            $wanted += "split_config.x86.apk"
        }

        foreach ($name in $wanted) {
            $path = Join-Path $work $name
            if (Test-Path $path) { $splits += $path }
        }

        Write-Host "Installing SoundCloud via install-multiple ($($splits.Count) APKs)..."
        $multi = @("install-multiple", "-r", "-g") + $splits
        $code = Try-Adb -AdbArgs $multi
        if ($code -ne 0) {
            Write-Host "install-multiple -g failed; retrying without -g..."
            $multi2 = @("install-multiple", "-r") + $splits
            Invoke-Adb -AdbArgs $multi2
        }
    } finally {
        Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
    }
}

function Install-ApkWithRetry {
    param([System.IO.FileInfo]$Apk)
    Write-Host "Installing $($Apk.Name)..."
    $code = Try-Adb -AdbArgs @("install", "-r", "-g", $Apk.FullName)
    if ($code -ne 0) {
        Write-Host "install -g failed; retrying without -g / with --user 0..."
        $code = Try-Adb -AdbArgs @("install", "-r", "--user", "0", $Apk.FullName)
        if ($code -ne 0) {
            Invoke-Adb -AdbArgs @("install", "-r", $Apk.FullName)
        }
    }
}

function Push-And-Scan-Mp3s {
    param([string]$Dir, [string]$RemoteDir)

    $mp3s = @(Get-ChildItem -Path $Dir -Filter "*.mp3" -ErrorAction SilentlyContinue)
    if (-not $mp3s) {
        Write-Warning "No MP3 files in $Dir"
        return
    }

    Write-Host "Creating $RemoteDir ..."
    [void](Try-Adb -AdbArgs @("shell", "mkdir", "-p", $RemoteDir))

    foreach ($mp3 in $mp3s) {
        $remotePath = "$RemoteDir/$($mp3.Name)"
        Write-Host "Push $($mp3.Name) -> $remotePath"
        Invoke-Adb -AdbArgs @("push", $mp3.FullName, $remotePath)

        # Android 13+ / AAOS: per-file scanner broadcast (URI must match pushed path)
        $fileUri = "file://$remotePath"
        Write-Host "Scan $fileUri"
        $scanCode = Try-Adb -AdbArgs @(
            "shell", "am", "broadcast",
            "-a", "android.intent.action.MEDIA_SCANNER_SCAN_FILE",
            "-d", $fileUri
        )
        if ($scanCode -ne 0) {
            Write-Warning "MEDIA_SCANNER_SCAN_FILE failed for $($mp3.Name) (exit $scanCode). LocalMediaService can still open by path."
        }
    }
}

# --- main ---
$script:ADB = Resolve-Adb -Preferred $AdbPath
$script:Serial = $Serial

if (-not (Test-Path $MediaDir)) {
    throw "MediaDir not found: $MediaDir"
}

Write-Host "ADB=$script:ADB"
Write-Host "Serial=$script:Serial"
Write-Host "MediaDir=$MediaDir"

# Ensure device is reachable (Carsky tunnel often needs connect)
if ($script:Serial -match "localhost:5555") {
    & $script:ADB connect localhost:5555 | Out-Null
}

$devicesOut = (& $script:ADB devices) -join "`n"
if ($devicesOut -notmatch [regex]::Escape($script:Serial)) {
    Write-Host $devicesOut
    throw "Device $script:Serial not in adb devices. Start Reach tunnel / emulator first."
}

$abi = Get-DeviceAbi
Write-Host "Device ABI=$abi"

if (-not $SkipApkInstall) {
    $yt = Select-YouTubeMusicApk -Dir $MediaDir -Abi $abi
    Install-ApkWithRetry -Apk $yt

    $sc = Select-SoundCloudApkm -Dir $MediaDir -Abi $abi
    if ($sc.Kind -eq "apk") {
        Install-ApkWithRetry -Apk $sc.File
    } else {
        Write-Host "Selected SoundCloud bundle: $($sc.File.Name)"
        Install-SoundCloudApkm -Apkm $sc.File -Abi $abi
    }

    Write-Host "`nInstalled packages (filter):"
    & $script:ADB -s $script:Serial shell pm list packages | Select-String -Pattern "youtube.music|soundcloud"
} else {
    Write-Host "Skipping APK install (-SkipApkInstall)"
}

if (-not $SkipMp3) {
    Push-And-Scan-Mp3s -Dir $MediaDir -RemoteDir $RemoteMusicDir
} else {
    Write-Host "Skipping MP3 push (-SkipMp3)"
}

if (-not $SkipLaunch) {
    Write-Host "`nLaunching music apps (first-run / session warm)..."
    [void](Try-Adb -AdbArgs @("shell", "monkey", "-p", "com.google.android.apps.youtube.music", "-c", "android.intent.category.LAUNCHER", "1"))
    Start-Sleep -Seconds 2
    [void](Try-Adb -AdbArgs @("shell", "monkey", "-p", "com.soundcloud.android", "-c", "android.intent.category.LAUNCHER", "1"))
}

Write-Host "`nDone."
Write-Host "YT Music: com.google.android.apps.youtube.music"
Write-Host "SoundCloud: com.soundcloud.android"
Write-Host "Local MP3s: $RemoteMusicDir"
Write-Host "Next: privapp MEDIA_CONTENT_CONTROL + cockpit MediaControllerRepository"
