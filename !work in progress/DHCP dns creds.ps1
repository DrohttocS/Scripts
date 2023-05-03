#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-DhcpAdmin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$DhcpAdmin = Get-StoredCredential -Target "$env:USERNAME-DhcpAdmin"
$dhcpsrv = Get-DhcpServerInDC | select -ExpandProperty DnsName

$session = New-PSSession  -ComputerName $dhcpsrv -EnableNetworkAccess -Credential $AdminCred -ErrorAction SilentlyContinue

$res = Invoke-Command -Session $session -ScriptBlock {

# Set-DhcpServerDnsCredential -Credential $using:DhcpAdmin -PassThru

Get-DhcpServerDnsCredential 

}



Remove-PSSession -Session $session


Enter-PSSession XSMLSOMC83 -Credential $AdminCred

Set-DhcpServerDnsCredential -ComputerName "DhcpServer03.Contoso.com"