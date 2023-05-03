Import-Module ActiveDirectory
$dc = Test-Path -Path CHS:
if(!($dc)){

#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


New-PSDrive `
    –Name KDS `
    –PSProvider ActiveDirectory `
    –Server "kinetek-ds.com" `
    –Credential $AdminCred  `
    –Root "//RootDSE/" `
    -Scope Global

    
}
Set-Location KDS: