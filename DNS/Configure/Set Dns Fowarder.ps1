$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name  | sort
$DCsess = New-PSSession -ComputerName $dcs -Credential $AdminCred

Invoke-Command -Session $DCsess -ScriptBlock{

$Fwd = Get-DnsServerForwarder
Remove-DnsServerForwarder -IPAddress $Fwd.IPAddress -PassThru -Force
Add-DnsServerForwarder -IPAddress 208.67.222.222,208.67.220.220 –PassThru
}
Remove-PSSession $DCsess
