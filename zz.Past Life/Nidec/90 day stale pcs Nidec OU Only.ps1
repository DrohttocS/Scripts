$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$pDNS = Get-DnsClientServerAddress -InterfaceAlias Ethernet | select ServerAddresses -ExpandProperty ServerAddresses
$pDNS = $pDNS[0] 
$pDNS = [System.Net.Dns]::GetHostByAddress($pDNS).HostName

$DaysInactive = 90
$Time2remove = 120
$rtime = (Get-Date).Adddays(-($Time2remove))
$time = (Get-Date).Adddays(-($DaysInactive))
# Set Date Stamp Format
$TDate = Get-Date -Format g
$body=@()

$body += "PC's to be disabled`r`n"
$pcs = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and Enabled -eq $true  -and OperatingSystem -like '*Server*'} -Properties LastLogonTimeStamp  -SearchBase "OU=NIDEC,DC=nidecds,DC=com" -SearchScope subtree   | select-object Name,@{Name="Logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} 
Foreach ($pc in $pcs)
{
   $name = $pc.Name
   $ldate = $pc.Logon
   Set-ADComputer  -Identity $name -Description "Disabled  - $TDate Lastlogin - $ldate::" -Enabled $false -Credential $AdminCred
   $body += "`r`n$name Was disabled - $TDate Lastlogin - $ldate"
}
    
$body