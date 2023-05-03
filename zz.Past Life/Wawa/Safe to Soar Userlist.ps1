$GGG = import-csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdmin.csv" 
$UnderScores = $GGG | ?{$_.user -like "*_*" -or $_.user -like  "*$" -or $_.user -eq ''} | sort -Unique user | Export-Csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdminSkipped-SaintyCheck.csv" -NoTypeInformation
$UserAccounts = $GGG | ?{$_.user -notlike "*_*" -and $_.user -notlike  "*$" -and $_.user -ne ''} # Filters out _ accounts, Machine accounts, and blank users 
$users = @()
$users = foreach($u in $UserAccounts){
    $user = $u.user
  try{
    $adu = Get-ADUser $user -Properties mail,displayname,CanonicalName -ErrorAction Stop
    
    New-Object PSObject -Property ([ordered]@{
            'User'  = $u.user
            'First' = if([string]::IsNullOrWhiteSpace($adu.GivenName)){'Blank'}Else{$adu.GivenName} 
            'Last' =  if([string]::IsNullOrWhiteSpace($adu.surname)){'Blank'}Else{$adu.surname} 
            'Group' = $u.admin.Trim()
            'Sever' = $u.server
            'Email' = if($adu.mail -inotmatch '@'){'No Mail'}Else{ $adu.mail}
            'Display Name' = $adu.displayname
            'Canonical Name' = $adu.CanonicalName

            })
    }catch{
       New-Object PSObject -Property ([ordered]@{
            'User'  = $u.user
            'First' = 'N/A'
            'Last' =  'N/A'
            'Group' = $u.admin.Trim()
            'Sever' = $u.server
            'Email' = 'N/A'
            'Display Name' = 'N/A'
            'Canonical Name' = 'N/A'
            })

    }
}
$users | Export-Csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdminUSER.csv" -NoTypeInformation
# citrix host 5151