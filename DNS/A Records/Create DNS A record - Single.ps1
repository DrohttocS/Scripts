#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
#$pDNS = Get-DnsClientServerAddress -InterfaceAlias Ethernet | Select-Object ServerAddresses -ExpandProperty ServerAddresses
#$pDNS = $pDNS[0] 
#$pDNS = [System.Net.Dns]::GetHostByAddress($pDNS).HostName
$pDNS ='amrndsvpdc03'
$pc = Read-Host "Name "
$ip = Read-Host "IP Address "

Clear-Host
#Add DNS
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
    Add-DnsServerResourceRecordA -name $using:pc -ZoneName "nidecds.com" -IPv4Address $using:ip
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


pause
$dcs = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }| Select-Object Name -ExpandProperty name | Sort-Object
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs

Do{
    $res = Invoke-Command -Session $session -ScriptBlock {Resolve-DnsName -Name $using:pc -ErrorAction SilentlyContinue}
    Get-Date
    $dccount = $session.count
    $prog = $res | Group-Object IPAddress| Select-Object count, name
    $count = $res.Count
    Write-Host "Checking $pc's DNS against $dccount DC's
        $Count of $dccount have updated"
    
    $count = $res.Count
    Start-Sleep -Seconds 30
    }
until ($count -eq $dccount)
Remove-PSSession $session
    



<#
#remove DNS
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
$pc = Read-Host "Name "
Remove-DnsServerResourceRecord -ZoneName "nidecds.com" -RRType "A" -Name $pc
}

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
