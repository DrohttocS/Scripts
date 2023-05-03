Import-Module ExchangeOnlineManagement
Install-Module -Name MSOnline
$O365creds = Get-StoredCredential -Target $env:USERNAME-O365   <# New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise #>

#  Install-Module -Name CredentialManager
                                 #  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
                                 $AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


Connect-ExchangeOnline -UserPrincipalName scottadmin@trailwestbank.onmicrosoft.com -Credential $O365creds
Connect-MsolService -Credential $AdminCred

