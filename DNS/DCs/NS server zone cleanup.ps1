#Run from NS server

$AllowedNS = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select HostName -ExpandProperty HostName | sort
$DNSZones = Get-DnsServerZone | ?{$_.zonetype -eq 'Primary'}  | select ZoneName -ExpandProperty ZoneName | sort
$DNSZones =  [System.Collections.ArrayList]$DNSZones
#removeing private zones
$DNSZones.Remove("0.in-addr.arpa")
$DNSZones.Remove("127.in-addr.arpa")
$DNSZones.Remove("255.in-addr.arpa")


$NS2remove =@()
$NS2remove += foreach($zone in $DNSZones){
        $NSservers = Get-DnsServerResourceRecord  –Name “@” –RRType NS -ZoneName $zone 
        $FilteredNSservers = $NSservers.recorddata.nameserver
        $FilteredNSservers = $FilteredNSservers | sort
        $NSservers=@()
        $NSservers += foreach($Fns in $FilteredNSservers){$Fns.Substring(0,$fns.Length-1)}
        sleep -Milliseconds 200
        $badNS = Compare-Object -ReferenceObject $AllowedNS -DifferenceObject $NSservers | select InputObject -ExpandProperty InputObject 
   New-Object PSObject -Property ([ordered]@{
            Zone = $zone
            'BadNS' = $badNS
            })
 
}

$test = $NS2remove | ?{$_.badns.Length -ge 1} 

foreach($zone in $test){
$z2clean = $zone.zone
Stop-Transcript 
Start-Transcript -Path "C:\temp\$z2clean.txt"
foreach ($BNS in $zone.BadNS){

Remove-DnsServerResourceRecord -ZoneName $z2clean -RRType Ns -Name "@"  -RecordData $BNS -Force -ErrorAction SilentlyContinue -PassThru 

}
}