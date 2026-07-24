<#
.SYNOPSIS
    Copies all Windows dotfiles to their target locations without symlinks,
    Developer Mode, or administrator elevation.

.DESCRIPTION
    This script is a standalone alternative to running dotbot with copy configs.
    It copies each dotfile using Copy-Item -Force, backs up any existing file
    before overwriting, and creates parent directories as needed.

    Run from any location — it uses $PSScriptRoot to locate the repo root.

.PARAMETER WhatIf
    Show what would be copied without actually copying anything.

.EXAMPLE
    .\install-windows-copy.ps1
    .\install-windows-copy.ps1 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
$RepoRoot   = Split-Path $PSScriptRoot -Parent
$BackupRoot = Join-Path $env:USERPROFILE ".dotfiles-backups"
$Timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupDir  = Join-Path $BackupRoot $Timestamp

# ---------------------------------------------------------------------------
# File list: each entry is [RelativeSourcePath, AbsoluteDestinationPath]
# ---------------------------------------------------------------------------
$Copies = @(
    # bash
    @( "common/bash/.bashrc",                  (Join-Path $HOME ".bashrc") ),
    @( "common/bash/.bash_profile",            (Join-Path $HOME ".bash_profile") ),
    # essentials
    @( ".aliases",                             (Join-Path $HOME ".aliases") ),
    @( ".exports",                             (Join-Path $HOME ".exports") ),
    # oh-my-posh
    @( "common/oh-my-posh/adisakshya.yaml",   (Join-Path $HOME "adisakshya.yaml") ),
    # powershell — both Windows PowerShell and PowerShell 7+
    @( "windows/powershell/profile.ps1",       (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1") ),
    @( "windows/powershell/profile.ps1",       (Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1") ),
    # vscode
    @( "common/vscode/settings.json",          (Join-Path $HOME "AppData\Roaming\Code\User\settings.json") ),
    # windows terminal (stable)
    @( "windows/windows-terminal/settings.json",
       (Join-Path $HOME "AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") ),
    # windows terminal preview
    @( "windows/windows-terminal/settings.json",
       (Join-Path $HOME "AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json") )
)

# ---------------------------------------------------------------------------
# Helper: back up a file if it already exists at the destination
# ---------------------------------------------------------------------------
function Backup-IfExists {
    param([string]$DestPath)

    if (Test-Path -LiteralPath $DestPath -PathType Leaf) {
        $Relative   = $DestPath.Replace($HOME, '~')
        $BackupPath = Join-Path $BackupDir ($DestPath.Replace($HOME, '').TrimStart('\').TrimStart('/'))

        if ($PSCmdlet.ShouldProcess($DestPath, "Back up to $BackupPath")) {
            $BackupParent = Split-Path $BackupPath -Parent
            if (-not (Test-Path $BackupParent)) {
                New-Item -ItemType Directory -Path $BackupParent -Force | Out-Null
            }
            Copy-Item -LiteralPath $DestPath -Destination $BackupPath -Force
            Write-Host "  Backed up: $Relative -> $BackupPath"
        }
    }
}

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
$Copied  = 0
$Skipped = 0

foreach ($Entry in $Copies) {
    $SrcRel  = $Entry[0]
    $Dest    = $Entry[1]
    $Src     = Join-Path $RepoRoot $SrcRel

    if (-not (Test-Path -LiteralPath $Src -PathType Leaf)) {
        Write-Warning "Source not found, skipping: $Src"
        $Skipped++
        continue
    }

    $DestDir = Split-Path $Dest -Parent

    Write-Host "Copying $SrcRel -> $Dest"

    if ($PSCmdlet.ShouldProcess($Dest, "Copy from $Src")) {
        # Ensure destination directory exists
        if (-not (Test-Path -LiteralPath $DestDir)) {
            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        }

        # Back up existing file before overwriting
        Backup-IfExists -DestPath $Dest

        Copy-Item -LiteralPath $Src -Destination $Dest -Force
        $Copied++
    }
}

Write-Host ""
Write-Host "Done. Copied: $Copied  Skipped: $Skipped"
if ($Copied -gt 0 -and (Test-Path $BackupDir)) {
    Write-Host "Backups stored in: $BackupDir"
}
