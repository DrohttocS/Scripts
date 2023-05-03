
Import-Module ActiveDirectory
Set-Location AD:
#Inactive Time
$DaysInactive = 7 
$time = (Get-Date).Adddays(-($DaysInactive))





$XP = Get-ADComputer -Server "bvb.local" -Filter{LastLogonTimeStamp -lt $time -and OperatingSystem -like "*7*"} `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
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
 #foreach($oldpc in $XP){Remove-ADObject $oldpc.DistinguishedName -Recursive -Confirm:$false}


