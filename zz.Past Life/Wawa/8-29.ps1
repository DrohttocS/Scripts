
#set Group lvl
Get-ADGroup LA_WSRV5058_LocalAdmin | Set-ADGroup -Replace @{info='PLvl:5'}


1 Domain User
2 
3
4 
5 Domain admin


Set-Location ad:
$acl = Get-ADGroup LA_WSRV5058_LocalAdmin| select -ExpandProperty DistinguishedName | get-acl

$acl.Access | sort IdentityReference | ft * -AutoSize 

$acl.Access | ?{$_.IdentityReference -like "*Users"} | FT




Set-Acl "ad:\CN=spstest1,OU=Spectre Test OU,OU=NSW,OU=Users,OU=XXX,DC=XXX,DC=local" -AclObject $acl