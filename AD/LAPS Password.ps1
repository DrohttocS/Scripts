#  Either install creditial manager and set-up admin creds or enter in you creds when prompted.
CLS
Write-Warning "Either install creditial manager and set-up admin creds or enter in you creds when prompted.
`t`t Ask Scott Hord for assistance if unsure how to install Credital Mgr.`n"
$Comp = Read-Host "Computer Name?"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
Get-adcomputer $comp  -Properties ms-Mcs-AdmPwd,CanonicalName,LastLogonDate -Credential $AdminCred | select Name,LastLogonDate,ms-Mcs-AdmPwd,CanonicalName,enabled