Get-ADUser -LDAPFilter "(name=*)" -SearchScope Subtree `
 -SearchBase "OU=Disabled users,DC=CHSspokane,DC=local" | %{
  $user = $_
   $user | Get-ADPrincipalGroupMembership | 
 Select @{N="User";E={$user.sAMAccountName}},@{N="Group";E={$_.Name}}
}| Select *|  Out-GridView