cls
$WSR_systems =  Get-ADComputer -Filter {name -like "WSRV*" -and enabled -eq $true}  | select -ExpandProperty Name

#region Pre-Flight
$counter = 0
$PreFlight = foreach($line in $WSR_systems){
    $counter++
    Write-Progress -Activity 'Processing computers' -CurrentOperation $line -PercentComplete (($counter / $WSR_systems.count) * 100)

$line| Test-NetConnection -CommonTCPPort WINRM | select ComputerName, TcpTestSucceeded | sort TcpTestSucceeded,Computername
}

$systems = $PreFlight |?{$_.TcpTestSucceeded -eq $true}
$PreFlightfail = $PreFlight |?{$_.TcpTestSucceeded -ne $true}
Write-host "RAW Systems: "$PreFlight.count
Write-host "Bad Systems: "$PreFlightfail.count
Write-host "Good Systems: "$systems.Count
$systems = $systems | select -ExpandProperty ComputerName
#endregion
$systems='wsrv5455'
 $success = $PreFlight |?{$_.TcpTestSucceeded -eq $true}



$ignore ='GatesW','Domain admins',"Corp_Solutions","serveradmin",'LA_Servers_All_LocalAdmin',"SVC","SQLAdmin","Administrator","LA_Servers_AllCitrix_LocalAdmin"
CLS

$systems = Get-Random -InputObject $success | select -ExpandProperty computername
$srv= foreach($system in $systems){
 Try{Start-Transcript  -Path "C:\Temp\Safe2Soar\Logs\$system.log" -Append
     $LAG = "LA_"+$system+"_LocalAdmin"
     $a =  Invoke-Command $system -ScriptBlock ${Function:get-la} -ErrorAction Stop
         Write-host "`nGetting Current Local Admins from $system`n"
         $b = $a | Select-String -NotMatch $ignore  |Out-String -Stream -PipelineVariable SamAccountName |?{$_.length -ge 1}
         
         If($b -notcontains "$LAG"){
            Write-Host -ForegroundColor Red "Missing LA Account`nCorrecting.."
                 Invoke-Command $system -ScriptBlock {
                    Write-host "ADDING LA Group: $using:lag"
                    Add-LocalGroupMember -Group "Administrators" -Member $using:LAG 
                  }
            $a =  Invoke-Command $system -ScriptBlock ${Function:get-la} -ErrorAction Stop
            $b = $a | Select-String -NotMatch $ignore  |Out-String -Stream -PipelineVariable SamAccountName |?{$_.length -ge 1}

           }#endif
                  
         $b |  ADO-Flow
    }
 Catch{ Write-Host $_.ScriptStackTrace
        Write-Warning "Failed to connect to $system"
       "Failed to connect to $system" | Out-File -FilePath  C:\temp\sa_\WinRM_Failure.csv -Append }
 Finally{
        Write-Host "Checked on $system account:`n"$b
        Write-Host "Raw Accts on $system account:`n"$a
        Stop-Transcript}
 }
