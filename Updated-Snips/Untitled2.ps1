import-module activedirectory

New-PSDrive `
    –Name BVB `
    –PSProvider ActiveDirectory `
    –Server "bvb-dc1.bvb.local" `
    –Credential (Get-Credential "bvb\scottadmin") `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location BVB:


    $XP = Get-ADComputer -Filter {OperatingSystemVersion -ge 5.1}`
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

              $XP | Out-GridView



              ## Define the username that’s locked out
$Username = ‘abertram’

## Find the domain controller PDCe role
$Pdce = (Get-AdDomain).PDCEmulator

## Build the parameters to pass to Get-WinEvent
$GweParams = @{
     ‘Computername’ = $Pdce
     ‘LogName’ = ‘Security’
     ‘FilterXPath’ = "*[EventData[Data[@Name='TargetUserName']='$swsvcs']]"
}

## Query the security event log
$Events = Get-WinEvent @GweParams



$pdc = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ } | select name

foreach ($dc in $pdc){
Get-Eventlog -logname "security" -computername $dc -WarningVariable
}

$S = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ } | select name
ForEach ($Server in $S) {$Server; Get-WinEvent -ListLog "Windows PowerShell" -Computername $Server}

getGet-WinEvent 