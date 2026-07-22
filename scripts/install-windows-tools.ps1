$ErrorActionPreference = 'Stop'

$OhMyPoshVersion = '29.34.0'
$OhMyPoshSha256 = '4de216d90a1432ae00fa0aceeef189b7e0fae470574b2c33a3927ea5f0d5ac15'
$OhMyPoshUrl = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v$OhMyPoshVersion/posh-windows-amd64.exe"
$InstallDirectory = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin'
$TemporaryFile = Join-Path ([System.IO.Path]::GetTempPath()) "oh-my-posh-$OhMyPoshVersion.exe"

try {
    Invoke-WebRequest -UseBasicParsing -Uri $OhMyPoshUrl -OutFile $TemporaryFile
    $ActualSha256 = (Get-FileHash -Algorithm SHA256 $TemporaryFile).Hash.ToLowerInvariant()
    if ($ActualSha256 -ne $OhMyPoshSha256) {
        throw "Checksum mismatch for oh-my-posh $OhMyPoshVersion"
    }

    New-Item -ItemType Directory -Force -Path $InstallDirectory | Out-Null
    Move-Item -Force $TemporaryFile (Join-Path $InstallDirectory 'oh-my-posh.exe')
} finally {
    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryFile
}
