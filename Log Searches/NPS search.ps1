$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$npsSvr = "DALUSEQXVPNP01"  #"AMRNDSVPNP01","AMRNDSVPNP02","EMANDSVPNP01",
$res = $null
$session = New-PSSession -ComputerName $npsSvr -Credential $AdminCred
$who = Read-Host "What are we looking for "
$res = Invoke-Command -Session $session -ScriptBlock{


$header = "Log File","ComputerName","ServiceName","Record-Date","Record-Time","Packet-Type","User-Name","Fully-Qualified-Distinguished-Name","Called-Station-ID","Calling-Station-ID",`
"Callback-Number","Framed-IP-Address","NAS-Identifier","NAS-IP-Address","NAS-Port","Client-Vendor","Client-IP-Address","Client-Friendly-Name","Event-Timestamp","Port-Limit","NAS-Port-Type"`
,"Connect-Info","Framed-Protocol","Service-Type","Authentication-Type","Policy-Name","Reason-Code","Class","Session-Timeout","Idle-Timeout","Termination-Action","EAP-Name","Acc-Status-Type"`
,"Acc-Delay-Time","Acc-Input-Octets","Acc-Output-Octets","Acc-Session-ID","Acc-Authentic","Acc-Input-Packet","Acc-Output-packet","acc-terminate-Cause","acc-multi-ssn-ID","acc-link-Count"`
,"Acc-Interim-Interval","tunnel-type","tunnel-medium-type","tunnel-client-endpoint","tunnel-server-endpoint","Acc-tunnel-conn","tunnel-pvt-group-ID","tunnel-assignment-id","Tunnel-Preference"`
,"MS-acc-auth-type","MS-acc-EAP-Type","MS-RAS-Version","MS-RAS-Vendor","MS-CHAP-Error1","MS-CHAP-Error","MS-CHAP-Domain","MS-MPPE-Encryption-Types","MS-MPPE-Encryption-Policy","Proxy-Policy-Name","Provider-Type"

$data = Select-String  -Path 'C:\Windows\system32\LogFiles\in*.log' -Pattern $using:who 
$data1 = $data
#fix stuff

$data1 = $data1 -replace(':"',',"')
$dataset = $data1 |select  | ConvertFrom-Csv -Delimiter "," -Header $header 
$dataset
}
Remove-PSSession $session

$res | select "ComputerName","ServiceName","Record-Date","Record-Time","User-Name","Fully-Qualified-Distinguished-Name","Called-Station-ID","Calling-Station-ID","NAS-IP-Address","NAS-Port","Client-Vendor","Client-IP-Address","NAS-Port-Type","Authentication-Type","Policy-Name","Reason-Code","class"|?{$_."Record-Date" -like "08/15*"} | Export-Csv -Path C:\Temp\Gian.csv
 