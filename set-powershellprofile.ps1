function prompt {
$color = Get-Random -Min 1 -Max 16
Write-Host ($(Get-Date -UFormat "#%a-%d_%I:%M") +"||" + (split-path (get-location) -Leaf) +">") -NoNewLine `
-ForegroundColor $Color
return " "
}
prompt
clear
