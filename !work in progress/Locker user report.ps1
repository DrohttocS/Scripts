#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$locked = Search-ADAccount -UsersOnly  -lockedout | Where-Object {$_.Enabled -eq $true}| Select-Object Name, SamAccountName | Sort-Object SamAccountName
