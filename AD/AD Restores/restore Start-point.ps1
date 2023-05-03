## https://sysadminguides.org/2017/04/20/restore-ad-objects-and-users-using-powershell-restore-adobject/

Get-ADObject -IncludeDeletedObjects -Filter {objectclass -eq 'group' -and isdeleted -eq $true -and Name -like "*rab*"} -Properties * | Out-GridView


Get-ADObject -filter 'msds-lastKnownRdn -eq "RAB" -and lastKnownParent -eq ",OU=RAB,OU=EMA,OU=LS,DC=nidecds,DC=com"' -includeDeletedObjects #| Restore-ADObject


Get-ADObject -filter 'isdeleted -eq $true -and name -ne "Deleted Objects" -and ObjectClass -eq "organizationalUnit"' -includeDeletedObjects -property * | ft Name,ObjectClass,ObjectGuid -Wrap


ForEach ($SamAccountName in Get-Content "C:\Samaccounts.txt"){
$user = $SamAccountName 
Get-ADObject -Filter {samaccountname -eq $user} -IncludeDeletedObjects -Properties * | ForEach-Object {Restore-ADObject $_.objectguid -NewName $_.samaccountname -TargetPath $_.LastKnownParent}
}