#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Enter-PSSession -ComputerName AMRNDSVPDC03 -Credential $AdminCred
Import-Module activedirectory

$testOU = 'OU=Hoffman Estates,OU=AMR,OU=NIDEC,DC=nidecds,DC=com'
Set-Location AD:
get-acl -Path "OU=Hoffman Estates,OU=AMR,OU=NIDEC,DC=nidecds,DC=com" | fl