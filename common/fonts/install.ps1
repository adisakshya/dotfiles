<#
.SYNOPSIS
    Installs the provided fonts.
.DESCRIPTION
    Installs all the provided fonts by default.  The FontName
    parameter can be used to pick a subset of fonts to install.

    Fonts are installed to the per-user fonts directory
    ($env:LOCALAPPDATA\Microsoft\Windows\Fonts) and registered under
    HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts so that
    Windows recognises them immediately without a logout/login cycle.
    This approach requires no Administrator privileges and is available
    since Windows 10 build 1803.
.EXAMPLE
    C:\PS> ./install.ps1
    Installs all the fonts located in the Git repository.
.EXAMPLE
    C:\PS> ./install.ps1 furamono-, hack-*
    Installs all the FuraMono and Hack fonts.
.EXAMPLE
    C:\PS> ./install.ps1 d* -WhatIf
    Shows which fonts would be installed without actually installing the fonts.
    Remove the "-WhatIf" to install the fonts.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Specifies the font name to install.  Default value will install all fonts.
    [Parameter(Position=0)]
    [string[]]
    $FontName = '*'
)

# Per-user font directory — available since Windows 10 build 1803, no admin required.
# Using this instead of the Shell.Application NameSpace(0x14) / C:\Windows\Fonts approach
# which resolves to the system-wide directory and requires Administrator elevation.
$userFontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'

$fontFiles = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
foreach ($aFontName in $FontName) {
    Get-ChildItem $PSScriptRoot -Filter "${aFontName}.ttf" -Recurse | Foreach-Object {$fontFiles.Add($_)}
    Get-ChildItem $PSScriptRoot -Filter "${aFontName}.otf" -Recurse | Foreach-Object {$fontFiles.Add($_)}
}

foreach ($fontFile in $fontFiles) {
    if ($PSCmdlet.ShouldProcess($fontFile.Name, "Install Font")) {
        # Ensure per-user font directory exists.
        if (-not (Test-Path $userFontDir)) {
            New-Item -ItemType Directory -Path $userFontDir -Force | Out-Null
        }

        # Destination path in the per-user font directory.
        $destPath = Join-Path $userFontDir $fontFile.Name

        # Copy font file to per-user directory (overwrite if already present — idempotent).
        Copy-Item -Path $fontFile.FullName -Destination $destPath -Force

        # Determine the font's display name for registry registration.
        # Try to read the internal family name via PrivateFontCollection;
        # fall back to the filename without extension if introspection fails.
        $displayName = $fontFile.BaseName
        try {
            $pfc = New-Object System.Drawing.Text.PrivateFontCollection
            $pfc.AddFontFile($fontFile.FullName)
            if ($pfc.Families.Count -gt 0) {
                $displayName = $pfc.Families[0].Name
            }
            $pfc.Dispose()
        } catch {
            # PrivateFontCollection unavailable; filename without extension used as fallback.
        }

        # Build the registry value name based on the font format.
        $extension = $fontFile.Extension.ToLower()
        $fontType = if ($extension -eq '.otf') { 'OpenType' } else { 'TrueType' }
        $regValueName = "$($fontFile.BaseName) ($fontType)"

        # Register the font under HKCU so Windows recognises it immediately
        # without requiring a logout/login cycle.
        $regKey = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        if (-not (Test-Path $regKey)) {
            New-Item -Path $regKey -Force | Out-Null
        }
        New-ItemProperty -Path $regKey -Name $regValueName -Value $destPath -PropertyType String -Force | Out-Null
    }
}
