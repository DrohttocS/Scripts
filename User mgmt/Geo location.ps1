function Get-IPGeolocation {
 Param
 (
 [string]$IPAddress
 )
 $request = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$IPAddress"
 [PSCustomObject]@{
 IP      = $request.query
 City    = $request.city
 Country = $request.country
 Isp     = $request.isp
 }
}
$OutputFile = ".\IP_GeoLocation.csv"
$i = 0
$IPs = Get-Content ".\IPs.txt"

$IPs = $Ures
ForEach ($IP In $IPs) {
 $i++ # More than 45 queries per minute gets you banned from ip-api.com
 If ($i -gt 40) {
 Write-Host Just pausing a minute to avoid IP blocking from ip-api.com
 Start-Sleep 70
 $i = 0
 }

 Get-IPGeolocation($IP) | Select-Object IP, City, Country, Isp 
}



 $request = Invoke-RestMethod -Uri ('http://ipinfo.io/'+(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)
 [PSCustomObject]@{
 IP      = $request.IP
 City    = $request.city
 Region = $request.region
 country = $request.country
 Isp     = $request.org
 OutsideDNS = $request.hostname
 GeoCoord = $request.loc
 }
