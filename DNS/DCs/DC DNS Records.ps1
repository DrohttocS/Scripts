$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$res = Invoke-Command -ComputerName AMRNDSVPDC03 -Credential $AdminCred -ScriptBlock{
 $zones = "_msdcs.nidecds.com", "nidecds.com"  #zone names don't have trailing periods
 $ipaddr = "10.112.10.107"
 $servername = "AMRNDSVPDC04"

$zones |
     ForEach-Object{
         $fqdn = "{0}.{1}." -f $servername, $_   # make a FQDN and add a trailing period
         Get-DnsServerResourceRecord  -ZoneName $_ |
             Where-Object { 
                 $_.RecordData.IPv4Address -eq $ipaddr   -or
                 $_.RecordData.NameServer  -eq $fqdn     -or
                 $_.RecordData.DomainName  -eq $fqdn 
             } 
                 
         }
         }
         $res