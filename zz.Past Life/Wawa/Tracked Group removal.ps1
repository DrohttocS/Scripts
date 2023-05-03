Start-Transcript  -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\NO_GroupCleanup.txt" -Append
Stop-Transcript
$Rawtable = Import-Csv -Path "C:\Users\wcw101934\Downloads\KathyNon_SA_.csv"
$NO_table = $rawtable | ?{$_.keep -eq 'No'}
$NO_DA = $NO_table | ?{$_.usergroup -eq ''}

$GA = $Rawtable | ?{$_.usergroup -notlike "LA_*" -and $_.usergroup -ne ""}
$a = $ga| sort name | Group-Object -Property UserGroup -AsHashTable -AsString

foreach($line in $a.Keys) {
$line
$a.$line | ft
}

Invoke-Command wsrv1016,wsrv5120 -ScriptBlock{
    Remove-LocalGroupMember -Group "administrators" -Member SCIT
    }

Invoke-Command WSRV5022 -ScriptBlock{
    Remove-LocalGroupMember -Group "administrators" -Member MFI_APP_ACCESS
    }

    
    Invoke-Command WSRV5141,WSRV5149 -ScriptBlock{
    Remove-LocalGroupMember -Group "administrators" -Member AG_VPN_Reflexis
    }

   Invoke-Command WSRV5120 -ScriptBlock{
    Remove-LocalGroupMember -Group "administrators" -Member "Information Security Team" 
    }

    Invoke-Command WSRV1016,WSRV5120 -ScriptBlock{
    Remove-LocalGroupMember -Group "administrators" -Member SCIT
    }

        Invoke-Command WSRV5412 -ScriptBlock{
    Get-LocalGroupMember -Group "administrators"
    Add-LocalGroupMember -Group "administrators" -Member "AG_SAPBasisAdmin","AG_SAPPortalUser"
    Get-LocalGroupMember -Group "administrators"
        }


        Invoke-Command WSRV5412 -ScriptBlock{
   # Get-LocalGroupMember -Group "administrators"
   Remove-LocalGroupMember -Group "administrators" -Member "Information Security Team"
   # Get-LocalGroupMember -Group "administrators"
        }

Invoke-Command $system -ScriptBlock ${Function:get-la}