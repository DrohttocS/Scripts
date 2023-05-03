#
# Search for accounts with emails and without Proxy addresses
# Adds email address to Proxy attrib
#


$u2 =@()
cls
$users = Get-ADUser -SearchBase "OU=Family of Banks Users,DC=bvb,DC=local"  -LDAPFilter "(!ProxyAddresses=*)"| Select-Object samAccountName
$users = $users.samAccountName
foreach ($user in $users){$U2 += Get-ADUser -Identity $user -Properties * |?{$_.EmailAddress -ne $null} | select EmailAddress, name,samAccountName}

foreach ($user in $u2){
$proxyadd =@()
$proxyadd = "SMTP:"+$uSER.EmailAddress
Set-ADUser $User.SamAccountName -Add @{'ProxyAddresses'=$proxyadd} 
}