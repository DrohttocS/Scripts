$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort




$ips = @("192.168.2.15", "192.168.2.17",”192.168.100.15”)
Get-NetFirewallrule -DisplayName "ISE ID Mapping IPv4 Dynamic Ports" |Set-NetFirewallRule -RemoteAddress $iseServers

$res = Invoke-Command -Session $session -ScriptBlock {$iseServers = @('10.109.254.157','10.109.252.157','10.152.252.157','10.152.254.157')
Get-NetFirewallrule -DisplayName "ISE ID Mapping IPv4 Dynamic Ports" |Set-NetFirewallRule -RemoteAddress $iseServers}
