#Monday CAB
$cabSystems = import-csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\Newly Created La_ Groups.csv"
$winRM2 = $cabSystems | select -ExpandProperty name 
$winRM2 = $winRM2 -replace 'LA_','' -replace '_LocalAdmin',''

# check if Svr is up
$isup   = @()
$isDown = @()

$winRM2| ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            $isUP += $_
            Write-Host "$_ is online."            
                    } else 
                    { Write-Warning "$_ Not online or accessable."
            $isDown += $_
                    }     
}


$winRM = $isup| Test-NetConnection -CommonTCPPort WINRM | select ComputerName, TcpTestSucceeded | sort TcpTestSucceeded,Computername
$winRM | Group-Object TcpTestSucceeded 

$prob = $winRM | ?{$_.TcpTestSucceeded -eq $false}| select -ExpandProperty ComputerName 
$winRM2 = $winRM | ?{$_.TcpTestSucceeded -eq $true}| select -ExpandProperty ComputerName

foreach($P in $prob){ if (test-Connection -ComputerName $p -Count 1 -Quiet ){Write-Host "$p is online."}else{ Write-Warning "$p Not online or accessable."}     }



$counter = 0
Start-Transcript  -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\Log.txt" -Append
foreach($system in $winRM2){
    $counter++
    Write-Progress -Activity 'Processing computers' -CurrentOperation $line -PercentComplete (($counter / $winRM2.count) * 100)

    $LAG = "LA_" + $system + "_LocalAdmin"
    Write-Host "Connecting to $system"
Try{
        Invoke-Command $system -ScriptBlock{
                Function Get-LA{
                                $Administrators = Get-LocalGroup -SID 'S-1-5-32-544'
                                ## Get group members
                                $null = Add-Member -InputObject $Administrators -MemberType 'NoteProperty' -Force -Name 'Members' -Value (
                                    [string[]](
                                        $(
                                            [adsi](
                                                'WinNT://{0}/{1}' -f $env:COMPUTERNAME, $Administrators.'Name'
                                            )
                                        ).Invoke(
                                            'Members'
                                        ).ForEach{
                                          $([adsi]($_)).'path'.Split('/')[-1]
                                        }
                                    )
                                )
                                ## Output members
                             $Administrators.Members
                             }
                Write-host 'Getting Current Local Admins'
         $a = Get-LA
                Write-host "ADDING Acct: $using:lag"
            Add-LocalGroupMember -Group "Administrators" -Member $using:LAG 
                Write-host 'Checking Local Admins'
           $b=  Get-LA
           $c = Compare-Object $a $b | select -ExpandProperty InputObject
           if([string]::IsNullOrWhiteSpace($c)){Write-host "Failed Adding:$using:lag"}Else{Write-Host "Success ADDED Acct:$c"}
            }
    }Catch{
    Write-Warning "Failed To Connect : $system"
    }
        }
        Stop-Transcript



  Invoke-Command $system -ScriptBlock{
        $LAG = "LA_" + $using:system + "_LocalAdmin"
     Get-LocalGroupMember -Name administrators | select Name
    }




      Invoke-Command $system -ScriptBlock{
        $LAG = "LA_" + $using:system + "_LocalAdmin"
    Remove-LocalGroupMember -Group "administrators" -Member $LAG
    }


    Function Get-LA{
                                $Administrators = Get-LocalGroup -SID 'S-1-5-32-544'
                                ## Get group members
                                $null = Add-Member -InputObject $Administrators -MemberType 'NoteProperty' -Force -Name 'Members' -Value (
                                    [string[]](
                                        $(
                                            [adsi](
                                                'WinNT://{0}/{1}' -f $env:COMPUTERNAME, $Administrators.'Name'
                                            )
                                        ).Invoke(
                                            'Members'
                                        ).ForEach{
                                          $([adsi]($_)).'path'.Split('/')[-1]
                                        }
                                    )
                                )
                                ## Output members
                             $Administrators.Members
                             }