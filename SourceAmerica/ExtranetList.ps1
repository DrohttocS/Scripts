$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$azlist = Import-Csv -Path C:\Temp\extAllExternalUsers_2023-2-22.csv 

$res = foreach ($user in $azlist.userPrincipalName){
$obj= Get-ADUser -filter{UserPrincipalName  -eq  $user} -Properties * | select DisplayName,mail,UserPrincipleName,Company

New-Object PSObject -Property ([ordered]@{
    UPN = $user
    DisplayName = $obj.DisplayName
    extEmail = $obj.mail
    Company = $obj.company
})
}
$res | Export-Csv -Path c:\temp\Suraj-extUsers.csv -NoTypeInformation 