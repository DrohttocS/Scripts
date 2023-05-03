 cls
$dc01 = Read-Host "Dc's being swapped out"
$dc02 = Read-Host "Dc's being swapped IN"
$tempip = Read-Host "What is the temp IP"
$dc01IP = Resolve-DnsName -Name $dc01 -Server STLUSNDSVPDC02 | select -ExpandProperty IPaddress
$bizUnit = $dc01.Substring(2,3)

$SD = "Windows 2012 Domain Controllers - $bizUnit  $dc01/$dc02 replacement"
$Reason = "$dc01 is a 2012r2 and needs to be replaced as its EOS."
$Plan =
 "
Promo $dc02, reach out to sec team and add to ISE, configure DNS logging, and let settle. Verify that the server is running error free.`n
On the day of the swap.

Connect to $dc01 update IP to temp IP $tempip
Reconnect to server via temp IP
Stop AD services 
Restart AD services

Connect to $dc02  update IP to  $dc01IP
Flushdns cache
Stop and restart AD Services (AD Services, and Netlogon)

Let changes replicate.

Run NSLookup scripts verify that new IPS have updated across the enterprise.
Send email notification to Onsite Tech"

$RiskAnalysis =
"Possible issues:
`t`t`tDNS Issues,
`t`t`tUmbrella/ISE blocking web traffic
`t`t`tLogon Issues
 "
 $BackoutPlan =
 "Roll-back to the original DC, or
 Update sites and service to have those Subnets AUTH against a different server."
 $testPlan = " Have the local tech verify Logon, and internet access."
 cls
 Write-Host "
 Short Discription`n$sd`n
 Description`nWe recently began replacing our Windows 2012 DC's with Windows 2019. Getting all the DC's on Windows 2016 & 2019 will provide us the opportunity to update the AD Feature Release Level, not to mention, to have our DC's on a current OS with a longer lifecycle.`n
 Justification`n$Reason`n
 Plan`n$Plan`n
 Risk`n$RiskAnalysis`n
 Backout Plan`n$BackoutPlan`n
 Test Plan`n$testPlan`n

 
 "