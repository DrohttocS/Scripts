
#######
#  StorSimple 
#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-StorSimple" -Persist Enterprise
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
Set-Item wsman:\localhost\Client\TrustedHosts 10.109.1.40 -Concatenate -Force

$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$Cred = Get-StoredCredential -Target "$env:USERNAME-StorSimple"

Enter-PSSession -Credential $cred -ConfigurationName SSAdminConsole -ComputerName 10.109.1.40 # control 0
Enter-PSSession -Credential $cred -ConfigurationName SSAdminConsole -ComputerName 10.109.1.43 # control 4 
Enter-PSSession -Credential $cred -ConfigurationName SSAdminConsole -ComputerName 10.109.1.45 # DNS

# export-hcssupportpackage -path \\172.16.10.135\Users\sysadmin\Desktop\sslogs -include all -credential d_nexus1\administrator
te
Invoke-WebRequest -Uri https://pod01-cis1.wcus.storsimple.windowsazure.com/ -UseBasicParsing
 Test-HcsmConnection

Enter-HcsSupportSession #pwd  hFGVaTv939cdXx8

Get-PhysicalDisk|Sort MediaType,friendlyname| FT -Property physicallocation, friendlyname, mediatype, healthstatus -AutoSize
HCS_xutil cli dumpdrives


export-hcssupportpackage -path "\\10.112.10.28\NC Systems\StorSimple" -include all -credential nidecds\admshord


Get-NetAdapter -Name 'Ethernet 2' -Verbose
Exit-PSSession