#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$pDNS = 'AMRNDSVPDC03'
$host2create = Import-Csv -Path "C:\Users\nmc77pw\Documents\Temp\DNS_ALIAS.csv"



foreach($record in $host2create){
$ServerName = $record.ServerName
$ARecord = $record.ARecord
$CNAMERecord = $record.CNAMERecord
$IP = $record.IP

Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{ 
        Add-DnsServerResourceRecordCName -Name $using:ServerName -HostNameAlias $using:ARecord -ZoneName nidecds.info
        sleep -Seconds 2
        Resolve-DnsName $using:CNAMERecord -Server AMRNDSVPDC03
        }    
}
$res = @()
foreach($record in $host2create){
$ServerName = $record.ServerName
$ARecord = $record.ARecord
$CNAMERecord = $record.CNAMERecord
$IP = $record.IP

$res += Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{ 

        Resolve-DnsName $using:CNAMERecord -Server AMRNDSVPDC03
        }    
}


$res |?{$_.QueryType -eq 'Cname'}|select 'QueryType','Server','NameHost','Name'| ft -AutoSize
