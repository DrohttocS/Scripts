$DNSServer = "dns01.rcmtech.co.uk"
$ZoneName = "rcmtech.co.uk"
$ReverseZoneName = "168.192.in-addr.arpa"
$NodeARecord = $null
$NodePTRRecord = $null

Write-Host "Check for existing DNS record(s)"
$NodeARecord = Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $NodeToDelete -RRType A -ErrorAction SilentlyContinue
if($NodeARecord -eq $null){
    Write-Host "No A record found"
} else {
    $IPAddress = $NodeARecord.RecordData.IPv4Address.IPAddressToString
    $IPAddressArray = $IPAddress.Split(".")
    $IPAddressFormatted = ($IPAddressArray[3]+"."+$IPAddressArray[2])
    $NodePTRRecord = Get-DnsServerResourceRecord -ZoneName $ReverseZoneName -ComputerName $DNSServer -Node $IPAddressFormatted -RRType Ptr -ErrorAction SilentlyContinue
    if($NodePTRRecord -eq $null){
        Write-Host "No PTR record found"
    } else {
        Remove-DnsServerResourceRecord -ZoneName $ReverseZoneName -ComputerName $DNSServer -InputObject $NodePTRRecord -Force
        Write-Host ("PTR gone: "+$IPAddressFormatted)
    }
    Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -InputObject $NodeARecord -Force
    Write-Host ("A gone: "+$NodeARecord.HostName)
}

$ListOfHosts = @("Server1","Server2","Server3")
foreach ($HostToDelete in $ListOfHosts){
$DNSDirectZone = $env:userdnsdomain
$DNSServer = $env:logonserver -replace '\\',''

$DNSARecord = Resolve-DnsName $HostToDelete
$AHostName = $DNSARecord.Name -replace $DNSDirectZone,"" -replace "\.$",""

$DNSPtrRecord = Resolve-DnsName $DNSARecord.IPAddress
$DNSReverseZone = (Get-DnsServerZone -ComputerName $DNSServer | ?{$DNSPtrRecord.Name -match $_.ZoneName -and $_.IsDsIntegrated -eq $true}).ZoneName

$PtrHostName = $DNSARecord.IPAddress -split "\."
[array]::Reverse($PtrHostName)
$PtrHostName = $PtrHostName -join "." -replace $DNSReverseZoneSuffix,"" -replace "\.$",""

if ($DNSPtrRecord.NameHost -eq $DNSARecord.Name) {
Remove-DnsServerResourceRecord -ComputerName $DNSServer -ZoneName $DNSReverseZone -Name $PtrHostName -RRType Ptr -Confirm:$false -Force
}

Remove-DnsServerResourceRecord -ComputerName $DNSServer -ZoneName $DNSDirectZone -Name $AHostName -RRType A -Confirm:$false -Force
}