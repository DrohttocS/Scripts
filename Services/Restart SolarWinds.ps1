$dcs = "CMDMXNDSVPDC01"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


Invoke-Command -ComputerName $dcs -Credential $AdminCred -ScriptBlock{
Get-Service "solar*" | Start-Service
Sleep -Seconds 5
Get-Service "solar*"
}



