#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$pDNS = "STLUSNDSVPDC02"
$pc = Read-Host "Name "
$ip = Read-Host "IP Address "
$zone = 'nmcres.org'
Clear-Host
#Add DNS
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
    Add-DnsServerResourceRecordA -name $using:pc -ZoneName $using:zone -IPv4Address $using:ip
    Start-Sleep -Seconds 5
    }

$NewArec = Resolve-DnsName -Server $pDNS -Name "$pc.$zone"
$utc = get-date -UFormat  (Get-Date).ToUniversalTime()
Write-Host "I have created the requested DNS A record for:"
$NewArec 
Write-host "`nThe requested  record changes are currently replicating as of $utc UTC. Please allow roughly an hour for replication to complete.`n`nRegards,`nScott"