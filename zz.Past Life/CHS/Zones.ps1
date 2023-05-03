$_RegKeyList1 = @()
$_RegKeyList2 = @()
$_RegKeyList3 = @()
$_RegKeyInfo  = @()


$_RegKeyList1 = $(Get-item 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey' -ErrorAction SilentlyContinue).property  


$_RegKeyList2 = $(Get-item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey' -ErrorAction SilentlyContinue).property 

$_RegKeyList3 = $_RegKeyList1 + $_RegKeyList2 
 $_RegKeyList3 | Out-GridView