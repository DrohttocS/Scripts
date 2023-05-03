$Computerlist = "6BBZX12-NOV14","ABB-CPROC-0719","ABB-JAIMEE-2019","ABB-JWORTH-1219","ABB-RTRIP-0916","CFUGE-1212","DESKTOP-O4IDN4F","EB-ROD-0615","EHEIBERGER-","212","EV-OPERATIONS-W","EVR-AMP01-0615","EVR-OPER-0615","EVR-TELLER01","EVR-TLR03-0618","FETCHER","FOBOPTI380-PC","FRN-BCLAR-0319","GGYFFZ1-011","","H6VNCX1-0413","HAB-CHKSVR-0519","HAM-CSR3-0319X","HAM-DJOSE-0120","HAM-IT1X-0518","HAM-JEAN-0317","HS1-DSHEETS","HS1-TLR01X-0519","JWORTH-011","","KAL-LACEY-0319","KAL-LOAN04-0618","KAL-NACT3-1118","KAL-ROD-0616","LLO-AUDIT-1119","llo-jalfr-0416","LLO-VDESK01","MARY-0116","MB-LOAN2-W","","MB-NEWACNTS1","MB-PROOF-1114","MBW-DUP01-0116","MBW-TLR01-0116","MBW-TLR02-0116","MDB-B8HGXM2","MDB-TLR03-1117","NICKDESK710","TWB-AMP-LLO","VIE","POINT713","WOB-BVB-1-813"
$dnsservers =@("192.168.100.53","192.168.0.53") 
 
foreach ($computername in $computerlist) { 
  if (test-Connection -ComputerName $computername -Count 1 -Quiet ) {  
         
    $result =  get-wmiobject win32_pingstatus -filter "address='$computername'" 
    if ($result.statuscode -eq 0) { 
        $remoteNic = get-wmiobject -class win32_networkadapter -computer $computername | where-object {$_.Speed -gt 1 -and $_.MACAddress -gt 1} 
        $index = $remotenic.index 
        $DNSlist = $(get-wmiobject win32_networkadapterconfiguration -computer $computername -Filter ‘IPEnabled=true’ | where-object {$_.index -eq $index}).dnsserversearchorder 
        $priDNS = $DNSlist | select-object -first 2 
        Write-host "Changing DNS IP's on $computername old DNS $pridns" -b "Yellow" -foregroundcolor "black" 
        $change = get-wmiobject win32_networkadapterconfiguration -computer $computername | where-object {$_.index -eq $index} 
        $change.SetDNSServerSearchOrder($DNSservers) | out-null 
        $changes = $(get-wmiobject win32_networkadapterconfiguration -computer $computername -Filter ‘IPEnabled=true’ | where-object {$_.index -eq $index}).dnsserversearchorder 
        Write-host "$computername's Nic1 Dns IPs $changes" 
    } 
    else { 
        Write-host "$Computername is down cannot change IP address" -b "Red" -foregroundcolor "white" 
    } 
}}