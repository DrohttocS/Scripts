#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
Get-ADReplicationSiteLinkBridge
Get-ADReplicationSubnet


netsh int ip reset
netsh int ip reset resettcpip.txt
netsh int ipv4 reset

ping 10.109.128.2..100

2..150 | % {"10.109.128.$($_): $(Test-Connection -count 1 -comp 10.109.128.$($_) -quiet)"}


Get-ADUser admin
