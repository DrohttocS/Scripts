$InterfaceAlias = Get-DnsClientServerAddress | ?{$_.ServerAddresses -eq '127.0.0.1'}| select -ExpandProperty InterfaceAlias -First 1

Set-DNSClientServerAddress $InterfaceAlias –ServerAddresses ("10.138.3.7", "10.112.10.91") 
Get-DnsClientServerAddress



Ipconfig /flushdns