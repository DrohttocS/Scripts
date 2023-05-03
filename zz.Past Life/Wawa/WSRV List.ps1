$Table = import-csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdmin.csv"
$Table = $Table  | ?{$_.server -ne "WSRV5151"}  # Remove Wsrv5151 - old citrix srv
$Table | Foreach-Object {$_.PSObject.Properties | Foreach-Object { $_.Value = $_.Value.Trim()}} # Trim Spaces

$res = $Table | select server -ExpandProperty server -Unique

 $res.Count
 $res1 = $res | ?{ $_.server -like "WSRV*"}
 $res1.count
 $Test_BSVR = $res1


 $Test_BSVR.Count
$res = foreach($LA in $Test_BSVR){

$prefix = "LA_"
$Suffix = "_LocalAdmin"
$New_LA_Group = $prefix+$LA+$Suffix
$DoesITExsist = ''
$DoesITExsist = [bool](Get-ADGroup $New_LA_Group )
$DoesITExsist = if($DoesITExsist -eq $true){Get-ADGroup $New_LA_Group -Properties Created}else{''}
# Testing 

  New-Object PSObject -Property ([ordered]@{
            Srv = $LA
            LAGroup  = if([string]::IsNullOrWhiteSpace($DoesITExsist)){'NO LA Group'}Else{$DoesITExsist.created} 
 }) 
 
 }
 $res | Out-GridView

 $res2 = $res | ?{$_.lagroup -eq 'NO LA Group'}
 $res2.count

 foreach($LA in $Test_BSVR){
$prefix = "LA_"
$Suffix = "_LocalAdmin"
$New_LA_Group = $prefix+$LA+$Suffix
Write-Host "Creating group $New_LA_Group"
New-ADGroup -Name $New_LA_Group -GroupScope Universal -GroupCategory Security -Path "OU=LocalAccessGroups,OU=AllGroups,DC=WAWA,DC=com" -Description "Priv Role, grants Local admin access to $la" -PassThru 
}


$LA = 'WSRV5757'
