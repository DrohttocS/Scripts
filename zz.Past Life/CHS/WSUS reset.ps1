#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise#
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Enter-PSSession -Credential $AdminCred -ComputerName llo-cred03-0519
Stop-Service -Name BITS, wuauserv -Force
Remove-ItemProperty -Name AccountDomainSid, PingID, SusClientId, SusClientIDValidation -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\ -ErrorAction SilentlyContinue
Remove-Item "$env:SystemRoot\SoftwareDistribution\" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name BITS, wuauserv
wuauclt /resetauthorization /detectnow
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()