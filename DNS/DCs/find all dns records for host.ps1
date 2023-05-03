$dc = 'GBU79PINFDC01*'
#get zones
$allZones = Get-DnsServerZone  | ?{$_.zonetype -eq 'Primary' -and $_.IsReverseLookupZone -eq $false} | select -ExpandProperty ZoneName




foreach($zone in $allZones){
#$zone
$dnsrecords = Get-DnsServerResourceRecord -ZoneName “$zone”
$deadDC = $dnsrecords | ?{$_.recorddata.nameserver -like $dc -or $_.recorddata.domainname -like $dc}
$deadDC
#$deadDC| Remove-DnsServerResourceRecord -ZoneName $zone -Force 

}
