$Table = import-csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdmin.csv"
$Table = $Table  | ?{$_.server -ne "WSRV5151"}  # Remove Wsrv5151 - old citrix srv
$Table | Foreach-Object {$_.PSObject.Properties | Foreach-Object { $_.Value = $_.Value.Trim()}} # Trim Spaces
$Table = $Table  | ?{$_.admin -notlike "*svc_*" -and $_.user -notlike  "*$"} # Filters out SVC_ accounts, Machine accounts

$Table | Out-GridView
$T1 = $Table | select -First 50
$T1 | Out-GridView
# Header User admin Server
Function User_check{
    if([string]::IsNullOrWhiteSpace($line.user)){'Blank'}Else{$line.user |SA_Check}
    }
Function SA_Check{
   Process{
   Try{if($_ -like "SA_*"){$true}else{[bool]("SA_" + $_ | Get-ADUser -ErrorAction SilentlyContinue)}}catch{Write-Output $_.exception.message}
           }
}
Function ADO_Type{
     Process{ 
      $ado = Get-ADObject -Filter {SamAccountName -eq $_}|select objectClass -ExpandProperty objectClass
         if ($ado.count -gt 0) {$ado} else {'Not in AD'}
         }

}
Function AG_CLeaner_Domain{
$u = if([string]::IsNullOrWhiteSpace($line.user)){'Blank'}Else{$line.user}
$b = $line.admin.split("\\")[0]
$c = if([string]::IsNullOrWhiteSpace($line.admin.split("\\")[-1])){'Blank'}Else{$line.admin.split("\\")[-1]}
$dt= if($b -eq 'CORPORATE' -or $b -eq 'Stores'){'CORP'}else{'Local'}
$d = $C | ADO_Type
$e = if ($d -eq 'user'){if([string]::IsNullOrWhiteSpace($c)){'Blank'}Else{$C|SA_Check}}
$f = if($u -ne 'Blank'){$u | SA_Check}else{$d}
$hash = @{     
                    User = $u
                    'Has an SA User account' = $f
                    Admin = $line.admin
                    Server = $line.server
                    Domain  = $b
					'AD Obj Type' = $d
					'User from Group' = $c
                    'Has an SA from Group' = $e
                    DomType =  $dt
                    				}
				$obj = new-object psobject -Property $hash
				$obj
			}



#$line.admin ="CORPORATE\SQLAdmin"
#        $line.user = ""
$counter = 0
$T3 = Foreach($line in $Table){
        $counter++
        Write-Progress -Activity 'Processing computers' -CurrentOperation $line -PercentComplete (($counter / $table.count) * 100)
    $line | AG_CLeaner_Domain
   }
   $t3 | Out-GridView

$T3 | Export-Csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\Refined_EveryLastAdmin_08152022.csv" -NoTypeInformation