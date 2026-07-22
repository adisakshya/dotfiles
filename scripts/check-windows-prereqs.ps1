# check-windows-prereqs.ps1
# Validates all prerequisites required to run "make windows" on Windows.
# Exits with code 1 and descriptive messages if any check fails.

$errors = @()

# --- Git ---
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Git is installed." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Git is not installed." -ForegroundColor Red
    $errors += "Git is not installed. Download it from https://git-scm.com/download/win"
}

# --- Bash (Git Bash or WSL) ---
$hasBash = (Get-Command bash -ErrorAction SilentlyContinue) -or (Get-Command wsl -ErrorAction SilentlyContinue)
if ($hasBash) {
    Write-Host "[OK] Bash is available (Git Bash or WSL)." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Bash is not available." -ForegroundColor Red
    $errors += "Bash is not available. Install Git for Windows (includes Git Bash) from https://git-scm.com/download/win, or enable WSL (https://learn.microsoft.com/en-us/windows/wsl/install)."
}

# --- Make ---
if (Get-Command make -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Make is installed." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Make is not installed." -ForegroundColor Red
    $errors += "Make is not installed. Run: winget install GnuWin32.Make"
}

# --- Symlink capability (Developer Mode or elevation) ---
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
