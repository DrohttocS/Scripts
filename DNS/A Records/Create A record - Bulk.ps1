#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$pDNS = 'AMRNDSVPDC03'
$host2create = Import-Csv -Path "c:\Temp\DNS-Batch.txt"

Clear-Host
#Add DNS


Foreach($record in $host2create){
$pc = $record.Hostname
$ip = $record.IP
Resolve-DnsName $pc -Server $pDNS -ErrorAction SilentlyContinue
Resolve-DnsName $ip -Server $pDNS -ErrorAction SilentlyContinue
}




foreach($record in $host2create){
$pc = $record.Hostname.Trim()
$ip = $record.IP.Trim()
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{ Add-DnsServerResourceRecordA -name $using:pc -ZoneName "nidecds.com" -IPv4Address $using:ip -createptr -passthru}
}    


$NewArec = foreach ($record in $host2create){
Resolve-DnsName -Server $pDNS -Name $record.Hostname -Type ANY
}
$utc = get-date -UFormat  (Get-Date).ToUniversalTime()
Write-Host "I have created the requested DNS A record for:"
$NewArec 
Write-host "`nThe requested  record changes are currently replicating as of $utc UTC. Please allow roughly an hour for replication to complete.`n`nRegards,`nScott"



    



<#
# Read host file and batch Create A records
$HF = Import-Csv 'C:\Users\nmc77pw\Documents\Temp\DNS - Batch.txt' 

Foreach($record in $HF){
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
Add-DnsServerResourceRecordA  -name $using:record.hostname -ZoneName "nidecds.com" -IPv4Address $using:record.ip 
}
}

foreach ($record in $HF){
Resolve-DnsName -Server $pDNS -Name $record.hostname
}
 #>
