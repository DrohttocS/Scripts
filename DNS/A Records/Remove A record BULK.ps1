#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$pDNS = 'AMRNDSVPDC03'


Clear-Host


#remove DNS
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
$pc = Read-Host "Name "
$lookup = Resolve-DnsName -Server $pDNS -Name $pc | Select-Object Name, IPAddress -ExpandProperty  IPAddress
sleep 2
Remove-DnsServerResourceRecord -ZoneName "nidecds.com" -RRType "A" -Name $pc 

    $tic ="Hi,
    I've removed the requested DNS A record for $pc.
    
    Name:$pc
    IP: $Lookup
    
    The requested change is currently replicating.
    

    
    Regards,
    Scott"
    $tic
}


