# Import modules
Import-Module posh-git
Import-Module PSReadLine

# Autocomplete
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Intellisense
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -HistoryNoDuplicates

# Set Oh My Posh prompt
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$HOME\adisakshya.yaml" | Invoke-Expression
}
