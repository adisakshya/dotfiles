# Import modules
Import-Module posh-git
Import-Module oh-my-posh
Import-Module PSReadLine

# Autocomplete
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Intellisense
Set-PSReadLineOption -ShowToolTips
Set-PSReadLineOption -HistoryNoDuplicates

# Set Oh My Posh prompt
Set-PoshPrompt -Theme ~/adisakshya.yaml
