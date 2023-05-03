#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs

$service = "SolarWindsAgent64"
$res = Invoke-Command -Session $session -ScriptBlock {Get-Service -Name $using:service}
Remove-PSSession $session
    $running = $res | ?{$_.Status -eq "Running"} 
    $stopped = $res | ?{$_.Status -ne "Running"} | select PSComputerName -ExpandProperty PSComputerName
    $Srv2TestCount = $res.Count
    $dcCount = $dcs.Count
    if($running.Count -lt 1){$srvcRunning = 0}else{$srvcRunning = $running.count}
    if($stopped.Count -lt 1){$srvcstopped = 0}else{$srvcstopped = $running.count}

# status report

$output = @"
DC Count: $dcCount
Dc's Tested: $Srv2TestCount

$service is running on $srvcRunning
$service is not Stopped on $srvcStopped 
$stopped
"@
$output



<# Test if app is installed

$res = Invoke-Command -Session $session -ScriptBlock {
$folder = "C:\Program Files\CrowdStrike"
if (Test-Path -Path $Folder) {$H = Hostname
Write-Host "$H CrowdStrike is installed"  -ForegroundColor Yellow
} else {$H = Hostname
    Write-Host "$H Crowdstrike is not installed!" -ForegroundColor Red
}
}
$res

#stop



$Failes = Compare-Object $res.Pscomputername $dcs |select inputobject -ExpandProperty InputObject
$session = New-PSSession -Credential $AdminCred  -ComputerName $Failes

$running

$folder = 'C:\Program Files (x86)\SolarWinds'
"Test to see if folder [$Folder]  exists"
if (Test-Path -Path $Folder) {
Write-Host "Path exists! "  -ForegroundColor Yellow
} else {
    Write-Host "Path doesn't exist." -ForegroundColor Red
}





if($stopped -ne $null){write-host "Service $service has stopped on:`n  $stopped"}

    while ($arrService.Status -ne 'Running')
    {

        Start-Service $service
        write-host $arrService.status
        write-host "$service starting"
        Start-Sleep -seconds 60
        $arrService.Refresh()
        if ($arrService.Status -eq 'Running')
        {
        Write-Host "$service is now Running"
        }
    }
}
Remove-PSSession $session
$res
#>