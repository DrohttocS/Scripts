# Find all DHCP Server in Domain
$DhcpServers = Get-DhcpServerInDC

foreach ($DHCPServer in $DhcpServers.DnsName){
if (Test-Connection -BufferSize 32 -Count 1 -ComputerName $dhcpserver -Quiet){
$ErrorActionPreference = “SilentlyContinue”
$Scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer
#For all scopes in the DHCP server, get the scope options and add them to $LIstofSCopesandTheirOptions
foreach ($Scope in $Scopes){
$LIstofSCopesandTheirOptions += Get-DHCPServerv4OptionValue -ComputerName $DHCPServer -ScopeID $Scope.ScopeId | Select-Object @{label=”DHCPServer”; Expression= {$DHCPServer}},@{label=”ScopeID”; Expression= {$Scope.ScopeId}},@{label=”ScopeName”; Expression= {$Scope.Name}},@{Name=’Value’;Expression={[string]::join(“;”, ($_.Value))}},*
}
$LIstofSCopesandTheirOptions += Get-DHCPServerv4OptionValue -ComputerName $DHCPServer | Select-Object @{label=”DHCPServer”; Expression= {$DHCPServer}},@{Name=’Value’;Expression={[string]::join(“;”, ($_.Value))}},*
$ErrorActionPreference = “Continue”
}
}

#Now we have them all, output them
#$LIstofSCopesandTheirOptions | Export-Csv -Path D:\EAADM\atrubajda\DhcpOptionsReport.csv -Force
$ListofScopesandTheirOptions | Out-GridView
#