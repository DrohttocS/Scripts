#######
#  
#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$mmsPath = "$env:SystemRoot\System32\mmc.exe" 
$mscPath = "$env:SystemRoot\System32\virtmgmt.msc"
$wdir = "C:\Program Files\Hyper-V"
Start-Process powershell -Credential $AdminCred -ArgumentList "Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $mscPath -Verb RunAs"
