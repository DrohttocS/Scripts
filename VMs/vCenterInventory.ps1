#Requires -Version 4
#Requires -Modules VMware.VimAutomation.Core

<# .SYNOPSIS Create an inventory in CSV format of virtual machines in vCenter. .DESCRIPTION This script is meant to perform an inventory of Virtual Machines. 
It can connect to multiple vCenters to pull statistics from and it can pull statistics from multiple Host Clusters. This script performs read-only operations. 
Output is formatted as CSV using a standard layout. Variable Details $vcs - An array containing the list of vCenter servers to connect to.
 $logFile - The location of where to save the output in CSV format. $vcsCluster - The name of the cluster. It accepts wildcard characters, but it cannot be empty. 
 $businessUnitName - the busines unit, group or department which owns/supports this environment Credential Requirements 
 $vcsCreds - A user credential that has access to login to vCenter with Read-Only rights at a minimum. $wmiCreds - A user credential that has access to perform WMI queries locally on the Windows Virtual Machines #>

Clear-Host
#  eqvc01.nish.org  vcsa65dr


# Edit these variables for your specific environment
$vcs = @("eqvc01") # FQDN of your vCenter server.
$logFile = "C:\Temp\VMInventory.csv" # Where you want to save the CSV file
$vcsCluster = "*" # Filters which cluster you want to pull VM stats from.
$businessUnitName = "SourceAmerica" # Name of Business Unit that the script is gathering stats for

if($vcs -contains "vCenterFQDN"){
$vcs = Read-Host -Prompt "FQDN of vCenter Server"
}
$vcsCreds = Get-StoredCredential -Target "$env:USERNAME-Admin"
#$vcsCreds = Get-Credential -Message "vCenter Credentials"
#$wmiCreds = Get-Credential -Message "WMI Credentials"

Import-Module VMware.VimAutomation.Core
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
Connect-VIServer $vcs -Credential $vcsCreds | Out-Null

$vms = Get-Cluster -Name $vcsCluster | Get-VM
$count = 0
$results = @()
#$Script:ProgressPreferenceOriginal = $ProgressPreference
#Clear-Host
$results += foreach($vm in $vms){
# Progress Bar setup
$count++
$percentComplete = [math]::Round(($count / $vms.Count) * 100,1)

Write-Progress -Activity "Collecting info on $($vm.Name)" -Status "$percentComplete% Complete" -PercentComplete $percentComplete

<# Store VM stat info in PSObject
$object = New-Object PSObject
Add-Member -InputObject $object -MemberType NoteProperty -Name BusinessUnit -Value $businessUnitName
Add-Member -InputObject $object -MemberType NoteProperty -Name Name -Value $vm.Name
Add-Member -InputObject $object -MemberType NoteProperty -Name Domain -Value (($vm.Guest.Hostname.Split('.') | Select-Object -Skip 1) -join '.')
#Add-Member -InputObject $object -MemberType NoteProperty -Name Location -Value " "
Add-Member -InputObject $object -MemberType NoteProperty -Name IPAddress -Value ($vm.Guest.IPAddress -join ", ")
#Add-Member -InputObject $object -MemberType NoteProperty -Name Function -Value " "
Add-Member -InputObject $object -MemberType NoteProperty -Name PorV -Value "Virtual"
Add-Member -InputObject $object -MemberType NoteProperty -Name vCluster -Value ($vm | Get-Cluster).Name
Add-Member -InputObject $object -MemberType NoteProperty -Name vHost -Value $vm.VMHost
Add-Member -InputObject $object -MemberType NoteProperty -Name Make -Value "N/A"
Add-Member -InputObject $object -MemberType NoteProperty -Name Model -Value "N/A"
Add-Member -InputObject $object -MemberType NoteProperty -Name SerialNumber -Value "N/A"
Add-Member -InputObject $object -MemberType NoteProperty -Name CPU -Value $vm.NumCpu
Add-Member -InputObject $object -MemberType NoteProperty -Name vSocket -Value ($vm.NumCpu / $vm.CoresPerSocket)
Add-Member -InputObject $object -MemberType NoteProperty -Name CoreCount -Value $vm.CoresPerSocket
Add-Member -InputObject $object -MemberType NoteProperty -Name Notes -Value if([string]::IsNullOrWhiteSpace($vm.notes)){''}Else{($vm.notes)}
Add-Member -InputObject $object -MemberType NoteProperty -Name MemoryGB -Value $vm.MemoryGB
Add-Member -InputObject $object -MemberType NoteProperty -Name OperatingSystem -Value $vm.Guest.OSFullName
Add-Member -InputObject $object -MemberType NoteProperty -Name UsedSpaceGB -Value ([math]::Round($vm.UsedSpaceGB, 0))
Add-Member -InputObject $object -MemberType NoteProperty -Name ProvisionedSpaceGB -Value ([math]::Round($vm.ProvisionedSpaceGB,0))
#Add-Member -InputObject $object -MemberType NoteProperty -Name Environment -Value " "
# Stores the PSObject containing VM stats in to an PSObject array #>



        $a = $businessUnitName
        $b = $vm.Name
        $c = (($vm.Guest.Hostname.Split('.')) | Select-Object -Skip 1) -join '.'
        $d = ($vm.Guest.IPAddress -join ", ")
        $e = "Virtual"
        $f = ($vm | Get-Cluster).Name
        $g = $vm.VMHost
        $h = $vm.VMHost.Manufacturer
        $i = $vm.VMHost.Model
        $j = $vm.NumCpu
        $k = ($vm.NumCpu / $vm.CoresPerSocket)
        $l = $vm.CoresPerSocket
        $m = if([string]::IsNullOrWhiteSpace($vm.notes)){''}Else{($vm.notes)}
        $n = $vm.MemoryGB
        $o = $vm.Guest.OSFullName
        $p = ([math]::Round($vm.UsedSpaceGB, 0))
        $q = ([math]::Round($vm.ProvisionedSpaceGB,0))
        $r = $vm.PowerState
        $s = $vm.Guest.Nics | select -ExpandProperty networkname
        $t = $vm.Guest.Nics | select -ExpandProperty Connected

New-Object PSObject -Property ([ordered]@{
        BusinessUnit = if([string]::IsNullOrWhiteSpace($a)){''}Else{($a)}
        Name =         if([string]::IsNullOrWhiteSpace($b)){''}Else{($b)}
        State =        if([string]::IsNullOrWhiteSpace($b)){''}Else{($r)}
        Domain =       if([string]::IsNullOrWhiteSpace($c)){''}Else{($c)}
        IPv4 =         if([string]::IsNullOrWhiteSpace($d)){''}Else{($d)}
        vNet =         if([string]::IsNullOrWhiteSpace($d)){''}Else{($s)}
        NicStatus =    if([string]::IsNullOrWhiteSpace($d)){''}Else{($t)}
        PorV =         if([string]::IsNullOrWhiteSpace($e)){''}Else{($e)}
        vCluster =     if([string]::IsNullOrWhiteSpace($f)){''}Else{($f)}
        vHost =        if([string]::IsNullOrWhiteSpace($g)){''}Else{($g)}
        Hostmfg =      if([string]::IsNullOrWhiteSpace($h)){''}Else{($h)}
        HostModel =    if([string]::IsNullOrWhiteSpace($i)){''}Else{($i)}
        CPU =          if([string]::IsNullOrWhiteSpace($j)){''}Else{($j)}
        vSocket =      if([string]::IsNullOrWhiteSpace($k)){''}Else{($k)}
        CoreCount =    if([string]::IsNullOrWhiteSpace($l)){''}Else{($l)}
        Notes =        if([string]::IsNullOrWhiteSpace($m)){''}Else{($m)}
        MemoryGB =     if([string]::IsNullOrWhiteSpace($n)){''}Else{($n)}
        OperatingSystem = if([string]::IsNullOrWhiteSpace($o)){''}Else{($o)}
        UsedSpaceGB =  if([string]::IsNullOrWhiteSpace($p)){''}Else{($p)}
        ProvisionedSpaceGB = if([string]::IsNullOrWhiteSpace($q)){''}Else{($q)}
        })
}

# The Sort-Object is specifically set up so that the Export-Csv and Out-GridView do not truncate the properties of the individual PSObjects in
# the array.
$results | Out-HtmlView -FilePath c:\temp\vCenterInventory.html 
$results | Export-Csv -Path $logFile -NoTypeInformation  -Force
Write-Host "Output saved to $logFile"

Import-Csv $logFile | Out-HtmlView -FilePath c:\temp\vCenterInventory.html 

Disconnect-VIServer -Server * -Confirm:$false -Force | Out-Null

