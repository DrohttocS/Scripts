#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
#$pDNS = Get-DnsClientServerAddress -InterfaceAlias Ethernet | Select-Object ServerAddresses -ExpandProperty ServerAddresses
#$pDNS = $pDNS[0] 
#$pDNS = [System.Net.Dns]::GetHostByAddress($pDNS).HostName
$pDNS = "AMRNDSVPDC03"
$pc = Read-Host "Name "
$ip = Read-Host "IP Address "
$zone = 'nidecds.com'
Clear-Host
#Add DNS
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
    Add-DnsServerResourceRecordA -name $using:pc -ZoneName $using:zone -IPv4Address $using:ip
    Start-Sleep -Seconds 5
    
    $tic ="
    I've created the requested DNS A record for $using:pc as requested.
    
    Name:$using:pc
    IP: $using:ip
    
    The requested change is currently replicating.
    

    
    Regards,
    Scott"
    $tic
}


$NewArec = foreach ($record in $host2create){
Resolve-DnsName -Server $pDNS -Name "$pc.$zone"
}
$utc = get-date -UFormat  (Get-Date).ToUniversalTime()
Write-Host "I have created the requested DNS A record for:"
$NewArec 
Write-host "`nThe requested  record changes are currently replicating as of $utc UTC. Please allow roughly an hour for replication to complete.`n`nRegards,`nScott"









<#
$dcs = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }| Select-Object Name -ExpandProperty name | Sort-Object
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs -ErrorAction SilentlyContinue

Do{
    $res = Invoke-Command -Session $session -ScriptBlock {Resolve-DnsName -Name $using:pc -ErrorAction SilentlyContinue}
    Get-Date
    $dccount = $session |? {$_.State -eq 'opened'};$dccount=$dccount.Count
    $prog = $res | Group-Object IPAddress| Select-Object count, name
    $count = $res.Count
    Write-Host "Checking $pc's DNS against $dccount DC's
        $Count of $dccount have updated`n`n"
    
    $count = $res.Count
    Start-Sleep -Seconds 90
    }
until ($count -eq $dccount)


Remove-PSSession $session
    
#>
