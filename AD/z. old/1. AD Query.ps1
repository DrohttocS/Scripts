
If (!(Test-Path CHS:))
{
import-module activedirectory

New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsdc01.CHSSpokane.local" `
    –Credential (Get-Credential "chsSpokane\hords") `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location CHS:
}


$XP = Get-ADComputer -Filter {OperatingSystem -like "*XP*"}`
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName |
    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-90))} |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
          Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        @{name='Owner';`
          Expression={$_.nTSecurityDescriptor.Owner}}, `
        DistinguishedName
         
      $XP | Export-CSV C:\Admin\XP30days.csv
      $XP | Out-GridView
      ($XP | Measure-Object).Count