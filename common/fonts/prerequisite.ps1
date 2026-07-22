# Check for elevation before modifying execution policy.
# Set-ExecutionPolicy at CurrentUser scope does not require Administrator rights, but
# a warning is printed here so users understand they may need elevation if the policy
# is restricted at the machine level.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script modifies the PowerShell execution policy for the current user. If the machine-level policy is more restrictive, run this script as Administrator."
}

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted