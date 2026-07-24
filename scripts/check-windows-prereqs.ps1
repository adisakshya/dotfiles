# check-windows-prereqs.ps1
# Validates all prerequisites required to run "make windows" on Windows.
# Exits with code 1 and descriptive messages if any check fails.
#
# Parameters:
#   -SkipSymlinkCheck  Omit the symlink/Developer-Mode check. Pass this flag
#                      when running the copy-based install (make windows-copy),
#                      which does not create symlinks and therefore has no need
#                      for Developer Mode or an elevated shell.

param(
    [switch]$SkipSymlinkCheck
)

$errors = @()

# --- Git ---
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Git is installed." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Git is not installed." -ForegroundColor Red
    $errors += "Git is not installed. Download it from https://git-scm.com/download/win"
}

# --- Bash (Git Bash required; WSL alone is not sufficient) ---
if (Get-Command bash -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Bash is available on PATH." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Bash is not available on PATH." -ForegroundColor Red
    $errors += "bash is not available on PATH. Install Git for Windows (https://git-scm.com/download/win) which includes Git Bash."
}

# --- PowerShell execution policy ---
$effectivePolicy = Get-ExecutionPolicy
if ($effectivePolicy -in @('Restricted', 'AllSigned')) {
    Write-Host "[FAIL] PowerShell execution policy '$effectivePolicy' will block install scripts." -ForegroundColor Red
    $errors += "PowerShell execution policy '$effectivePolicy' will block install scripts. Run: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned"
} else {
    Write-Host "[OK] PowerShell execution policy is '$effectivePolicy' (scripts can run)." -ForegroundColor Green
}

# --- Make ---
if (Get-Command make -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Make is installed." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Make is not installed." -ForegroundColor Red
    $errors += "Make is not installed. Run: winget install GnuWin32.Make"
}

# --- Python (required by dotbot for the symlink-based install) ---
$pythonFound = (Get-Command python -ErrorAction SilentlyContinue) -or (Get-Command python3 -ErrorAction SilentlyContinue)
if ($pythonFound) {
    Write-Host "[OK] Python found." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Python not found — install from https://python.org or via winget: winget install Python.Python.3" -ForegroundColor Red
    $errors += "Python is not installed. Install from https://python.org or run: winget install Python.Python.3"
}

# --- Symlink capability (Developer Mode or elevation) ---
# Skipped when -SkipSymlinkCheck is passed (e.g. for the copy-based install).
if (-not $SkipSymlinkCheck) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    $devMode = $false
    try {
        $regVal = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
        $devMode = ($regVal -eq 1)
    } catch {}

    if ($isAdmin) {
        Write-Host "[OK] Running as Administrator (symlink creation allowed)." -ForegroundColor Green
    } elseif ($devMode) {
        Write-Host "[OK] Developer Mode is enabled (symlink creation allowed)." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Symlink creation is not available." -ForegroundColor Red
        $errors += "Symlink creation requires either Developer Mode or an elevated (Administrator) shell.`n  - Enable Developer Mode: Settings > Privacy & security > For developers > Developer Mode`n  - Or re-run this terminal session as Administrator."
    }
}

# --- Summary ---
if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Prerequisites not met. Please resolve the following issues before running 'make windows':" -ForegroundColor Red
    foreach ($msg in $errors) {
        Write-Host ""
        Write-Host "  * $msg" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host ""
Write-Host "All prerequisites satisfied. Proceeding with installation." -ForegroundColor Green
