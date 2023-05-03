#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$pDNS = 'AMRNDSVPDC03'

# Gather Info
$host2Alias = Read-Host "What is the host name"
$host2Alias = Resolve-DnsName $host2Alias
$alias = Read-Host 'cName / Alias'
$OrgArec,$zone = $host2Alias.Name.Split('.',2)


# Verify





Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{ 


        Add-DnsServerResourceRecordCName -Name $using:alias -HostNameAlias $using:host2Alias.Name -ZoneName $using:zone -PassThru
        sleep -Seconds 2
        Resolve-DnsName $using:alias -Server AMRNDSVPDC03
        }    


