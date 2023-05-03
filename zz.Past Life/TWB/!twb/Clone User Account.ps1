

$CloneAC = Read-Host "Account to clone from: "
$user2copy = Get-ADUser -identity $CloneAC
$pcname = Read-Host "Account to clone to: "
#Remove-ADPrincipalGroupMembership -Identity (Get-ADUser -Identity $pcname )  -MemberOf $(Get-ADPrincipalGroupMembership -Identity (Get-ADUser -Identity $pcname )| Where-Object {$_.Name -ne "Domain Users"}) 
$CopyFromUser = Get-ADUser $user2copy -prop MemberOf
$CopyToUser = Get-ADUser $pcname -prop MemberOf
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser
 