#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise#
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$Grps2DEl = gc -Path C:\Support\Kate\GroupstoDelete.txt
foreach($grp in $Grps2DEl){
Remove-ADGroup -Credential $AdminCred -Server twb-dc1 -Identity $grp 

}$Grps2DEl | sort