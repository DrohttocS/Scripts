$GN = Read-host "Group Name"
$GM = Get-ADGroupMember -server twb-abb-dc -Identity $gn | select name
$GM = $GM.name

Write-Host "`n`r$GN`n"
$GM

