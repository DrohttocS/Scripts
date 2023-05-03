#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise#
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Enter-PSSession -ComputerName “llo-tlr02” -Credential $AdminCred
Set-Service CryptSvc -StartupType Disabled
Get-Service wuauserv, CryptSvc,BITS | Stop-Service
(Remove-Item "$env:SystemRoot\SoftwareDistribution\" -Recurse -Force )
Get-Service wuauserv, CryptSvc,BITS
sleep -Seconds 5
Set-Service CryptSvc -StartupType Automatic
Get-Service wuauserv, CryptSvc,BITS | Start-Service
Get-ItemProperty "$env:SystemRoot\SoftwareDistribution"
Exit-PSSession
