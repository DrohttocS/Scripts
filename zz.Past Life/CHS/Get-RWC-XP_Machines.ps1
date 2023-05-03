
Import-Module ActiveDirectory
Set-Location AD:
$fileName= get-date -format "d-mm-yy"
$ts = get-Date -Format d | foreach {$_ -replace "/",""}
$XP = Get-ADComputer -Server "bvb.local" -Filter {OperatingSystem -like "*xp*"} `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {$_.whenChanged -le $((Get-Date).AddDays(-90))} |
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
 #$CV = "C:\Users\scohor\Desktop\"+$filename + '_RWC_WIN7.csv'
 #$XP | Export-Csv $CV
 # foreach($oldpc in $XP){Remove-ADObject $oldpc.DistinguishedName -Recursive -Confirm:$false}


