$WarningPreference = "Stop"
if(!(get-module -list activedirectory)){"IT needs to install RSAT Tools for PowerShell for this to work"| Write-Warning}
Clear-Host
$DLEmail = Read-Host "Distribution list email address to search"
$Gname = Get-ADGroup -Filter {mail -eq $DLEmail} | select -ExpandProperty samaccountname 
Get-ADGroupMember -Identity $Gname -Recursive |  Get-ADUser -Properties DisplayName,EmailAddress | Select DisplayName,EmailAddress | Out-GridView


#Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature

