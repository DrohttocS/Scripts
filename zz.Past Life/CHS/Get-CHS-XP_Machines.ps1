
Import-Module ActiveDirectory
$ts = get-Date -Format d | foreach {$_ -replace "/",""}
$XP = Get-ADComputer -Server "BVB.LOCAL" -Filter {OperatingSystem -like "*7*"} `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-10))} |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
            Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        @{name='Owner';`
            Expression={$_.nTSecurityDescriptor.Owner}}, `
        DistinguishedName

 # View graphically
   $XP | Out-GridView
 # Dump to desktop

#$CV = 'C:\Users\shord2126\Desktop\'
#$XP | Export-Csv $CV


