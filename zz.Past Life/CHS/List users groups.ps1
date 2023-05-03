$CurrentUser = Read-Host "User name "
$CurrentUserGroups = (GET-ADUSER –Identity $CurrentUser –Properties MemberOf | Select-Object MemberOf).MemberOf 

foreach($group in $CurrentUserGroups) 
{ 
 $strGroup = $group.split(',')[0] 
 $strGroup = $strGroup.split('=')[1] 
 $strGroup 

} 
