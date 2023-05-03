$ou = Get-ADUser -SearchBase "OU=Disabled,DC=bvb,DC=local" -Filter *
foreach ($user in $ou) {
$UserDN = $user.DistinguishedName
Get-ADGroup -LDAPFilter "(member=$UserDN)" | foreach-object {
if ($_.name -ne "Domain Users") {remove-adgroupmember -identity $_.name -member $UserDN -Confirm:$False -WhatIf} }
}