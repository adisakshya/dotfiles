<#
.SYNOPSIS
    Single entry point for installing dotfiles on a fresh Windows machine.

.DESCRIPTION
    This script requires no Make, no bash — just PowerShell. It validates
    prerequisites, optionally installs fonts, and copies all dotfiles to their
    target locations using scripts/install-windows-copy.ps1.

    Ideal for fresh machines where Make is not yet installed.

.PARAMETER WhatIf
    Show what would be done without making any changes.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File install-windows.ps1
    powershell -ExecutionPolicy Bypass -File install-windows.ps1 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  dotfiles — Windows fresh-machine installer" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Installs dotfiles via file copies (no Make, no bash," -ForegroundColor Cyan
Write-Host "  no Developer Mode, and no admin elevation required)." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# PowerShell version check (informational — PS 5.1 ships with Windows 10+)
# ---------------------------------------------------------------------------
$psMajor = $PSVersionTable.PSVersion.Major
$psMinor = $PSVersionTable.PSVersion.Minor
Write-Host "[INFO] PowerShell $psMajor.$psMinor detected." -ForegroundColor Cyan
if ($psMajor -lt 5 -or ($psMajor -eq 5 -and $psMinor -lt 1)) {
    Write-Warning "PowerShell 5.1 or later is recommended. Some features may not work correctly."
}

# ---------------------------------------------------------------------------
# Step 1: Validate prerequisites (skip symlink check — we copy, not link)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 1/3: Checking prerequisites..." -ForegroundColor Cyan

$PrereqScript = Join-Path $PSScriptRoot "scripts\check-windows-prereqs.ps1"
if (-not (Test-Path -LiteralPath $PrereqScript)) {
    Write-Host "[ERROR] Prereq script not found: $PrereqScript" -ForegroundColor Red
    Write-Host "Make sure you are running this script from the dotfiles repository root." -ForegroundColor Yellow
    exit 1
}

try {
    & $PrereqScript -SkipSymlinkCheck
} catch {
    Write-Host ""
    Write-Host "[ERROR] Prerequisite check failed. Resolve the issues above, then re-run this script." -ForegroundColor Red
    exit 1
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Prerequisite check failed. Resolve the issues above, then re-run this script." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 2: Install fonts (optional — skipped if script is absent)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 2/3: Installing fonts..." -ForegroundColor Cyan

$FontScript = Join-Path $PSScriptRoot "common\fonts\install.ps1"
if (Test-Path -LiteralPath $FontScript) {
    if ($PSCmdlet.ShouldProcess($FontScript, "Run font installer")) {
        & $FontScript
    }
} else {
    Write-Host "[INFO] Font installer not found at $FontScript — skipping." -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# Step 3: Copy dotfiles
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 3/3: Copying dotfiles..." -ForegroundColor Cyan

$CopyScript = Join-Path $PSScriptRoot "scripts\install-windows-copy.ps1"
if (-not (Test-Path -LiteralPath $CopyScript)) {
    Write-Host "[ERROR] Copy script not found: $CopyScript" -ForegroundColor Red
    exit 1
}

if ($PSCmdlet.ShouldProcess($CopyScript, "Run dotfile copy installer")) {
    & $CopyScript
} else {
    & $CopyScript -WhatIf
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open a new terminal window to load the new PowerShell profile." -ForegroundColor Yellow
Write-Host "  2. If fonts were installed, restart your terminal app to pick up the" -ForegroundColor Yellow
Write-Host "     new Powerline font." -ForegroundColor Yellow
Write-Host "  3. To sync changes after editing dotfiles, re-run:" -ForegroundColor Yellow
Write-Host "     powershell -ExecutionPolicy Bypass -File install-windows.ps1" -ForegroundColor Yellow
Write-Host ""
