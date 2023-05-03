####### Pre-req ###########
#  Install-Module -Name CredentialManager
  New-StoredCredential -Comment 'O365' -Credentials $(Get-Credential) -Target $env:USERNAME-O365 -Persist Enterprise
  New-StoredCredential -Comment 'ADM' -Credentials $(Get-Credential) -Target $env:USERNAME-ADMIN -Persist Enterprise

