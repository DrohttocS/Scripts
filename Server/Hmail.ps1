#######
#  
#######
# New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-HMail"  -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-HMail"



