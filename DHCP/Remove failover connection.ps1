#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


Enter-PSSession -ComputerName amrndsvpdh01 -Credential $AdminCred



$failOver = Get-DhcpServerv4Failover | select name -ExpandProperty Name | ? {$_ -like "10.109.17.80*"}


$failOver | Remove-DhcpServerv4Failover -Force 

Exit-PSSession