$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$torestart = "MKTUSNDSVPDC01","SHVUSNDSVPDC01"


Foreach($dc in $torestart){

Write-Host "Restarting $dc"
Restart-Computer -ComputerName $dc -Credential $AdminCred -Force
sleep -Seconds 180

}


