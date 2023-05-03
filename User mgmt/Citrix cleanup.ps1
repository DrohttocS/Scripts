#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-nmcadmin" -Persist Enterprise
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$nmcadminCred = Get-StoredCredential -Target "$env:USERNAME-nmcadmin"



Enter-PSSession -ComputerName monmxnmcvpfs01 -Credential $AdminCred

$HomeFolders = GET-CHILDITEM "E:\Profiles\*old*" | select name -ExpandProperty name

$HomeFolders ="nmc09jf.V3","nmc09sb.upm_2021-05-19_11.55.54","srvc_embobinado.upm_2020-10-28_14.11.24","srvc_flechas4.V3"



foreach($citrixProf in $HomeFolders){
takeown /a /r /d Y /f E:\Profiles\$citrixProf
Remove-Item -path E:\Profiles\$citrixProf -Recurse -force -Credential $nmcadminCred
}



Exit-PSSession



