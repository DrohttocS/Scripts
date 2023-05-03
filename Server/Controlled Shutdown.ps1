function Reverse ()
{
    $arr = $input | ForEach-Object { $_ }
    [array]::Reverse($arr)
    return $arr
}
$shutdown = "SAADCS01","SA-EXCH2016","NAVMFOASDB01","NAVMFOASAPP01","NAVMFOASINT01","NAVMFOASREP01","NAVMREPTDB01","NAVMBT03","NAVMFOASAPP02","NAVMFOASEXT01","SASPDB01","SASPAPP0102","SASPAPP0103","NAVMCSTPRDDB01","NAVMCSTPRDAPP01","NAVMPLIMSPRD01","SASPDB02","SASPAPP0104","SASPAPP0105","SASPAPP0106","SASPAPP0107","SACOGPROD01","win10-siebeldev","navmbtdev03","navmbttst03","navmfoadevint01","navmfoadevdb01","navmfoadevapp01","navmreptdb01","NAVMCOGDEV03"
$NoOrder = "NAVMFOASAPP01","NAVMFOASINT01","NAVMFOASDB01","NAVMFOASREP01","NAVMREPTDB01","NAVMBT03","NAVMFOASAPP02","NAVMFOASEXT01"
$all = $NoOrder + $revorder

$revorder = $shutdown | reverse
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$counter = 0
$rc = $revorder.count
foreach ($Server in $revorder) {
$counter ++
$complete = (($counter / $rc)).ToString("P")
Write-host   "Shutting Down $Server`n`tPercentage Complete: $complete`n`t`tNumber $counter of $rc"
    Stop-Computer -ComputerName $Server -Credential $AdminCred 
    while (Test-Connection  $Server -Quiet) {Write-Host -ForegroundColor Yellow  "Waiting for $Server to stop responding to ping."
       Start-Sleep -Seconds 1}
}








$counter = 0
$rc = $NoOrder.count
foreach ($Server in $NoOrder) {
$counter ++
$complete = (($counter / $rc)).ToString("P")
Write-host   "Restarting $Server`n`tPercentage Complete: $complete`n`t`tNumber $counter of $rc"
    Restart-Computer -ComputerName $Server -Credential $AdminCred 
    while (Test-Connection -Ping $Server -Quiet) {Write-Host -ForegroundColor Yellow  "Waiting for $Server to stop responding to ping."
       Start-Sleep -Seconds 5}
}

$ses = New-PSSession $NoOrder -Credential $AdminCred

foreach($srv in $NoOrder){
Test-NetConnection $srv 
}

cls

$isup=@()
$isDown=@()
$Baddcs=@()
$all = "NAVMCOGDEV03","navmfoadevapp01","navmfoadevdb01","navmfoadevint01","navmbttst03","navmbtdev03","win10-siebeldev","NAVMPRINT01","SAEQCARD","NAFILE01","SACOGPROD01","SASPAPP0107","SASPAPP0106","SASPAPP0105","SASPAPP0104","SASPDB02","NAVMPLIMSPRD01","NAVMCSTPRDAPP01","NAVMCSTPRDDB01","SASPAPP0103","SASPAPP0102","SASPDB01","NAVMFOASEXT01","NAVMFOASAPP02","NAVMBT03","NAVMREPTDB01","NAVMFOASREP01","NAVMFOASINT01","NAVMFOASAPP01","NAVMFOASDB01","SA-EXCH2016"

$all | ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            $isup += $_
            Write-Host -f Green "$_ is UP"
                    } else 
                    { Write-Warning "$_ Not online or accessible"
             $Baddcs += $_
                    }     
}


$all.Count
$NoOrder.Count