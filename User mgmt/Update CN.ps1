$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$Users = Get-ADUser -SearchBase "OU=Users,OU=Accounts,OU=UK-Newtown-Unit79,OU=EMA,OU=CT,DC=nidecds,DC=com" -Filter {(GivenName -Like "*") -And (Surname -Like "cook*")} -Properties DisplayName | Select DisplayName, GivenName, Surname, Name, DistinguishedName
$Users
ForEach ($User In $Users)
{
    $DN = $User.DistinguishedName
    
    $First =$User.GivenName.TrimEnd()
    $First =$User.GivenName.TrimStart()
    $Last = $User.Surname
    $CN = $User.Name
    $Display = $User.DisplayName
    $NewName = "$Last, $First"
    If ($CN -ne $NewName) {Rename-ADObject -Identity $DN -NewName $NewName -Credential $AdminCred}
}$Users = Get-ADUser -SearchBase "OU=Users,OU=Accounts,OU=UK-Newtown-Unit79,OU=EMA,OU=CT,DC=nidecds,DC=com" -Filter {(GivenName -Like "*") -And (Surname -Like "cook*")} -Properties DisplayName | Select DisplayName, GivenName, Surname, Name, DistinguishedName
$Users
