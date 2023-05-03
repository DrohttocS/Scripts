$servers = "EHSPRINT01" #"WA9502wprint001","rwcprint","Rwcprint-mfp","RWCLABELPR"

$allprinters = @() 
foreach( $server in $servers ){ 
Write-Host "checking $server ..." 
$printer = $null 
$printers = $null 
$printers = Get-WmiObject -class Win32_Printer -computername $server 
$printer = $printers | where-object {$_.shared} 
#| select-object sharename, DriverName, PortName, SystemName, Location | Export-CSV .\process.csv  
$allprinters += $printer 
 } 
 Write-Host "exporting to printers.csv" 
$allprinters | select-object sharename, DriverName, PortName, SystemName, Location | Export-CSV .\printers.csv -NoTypeInformation 
Write-Host "Done!"