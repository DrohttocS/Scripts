$dcs = "KDM2MXNDSVPDC01"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Enter-PSSession -ComputerName $dcs -Credential $AdminCred
Get-Service "solar*" | Start-Service
Sleep -Seconds 5
Get-Service "solar*"

Exit-PSSession


