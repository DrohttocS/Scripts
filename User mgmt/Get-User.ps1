invoke-expression 'cmd /c start powershell -Command {
write-host "This is a wildcard search for the users username.`nEnter as much or as a little of what the login should be.`nExample: shord for a very narrow search or hor for a very broad search."
$who = Read-host "`n`nWho are we searching for(First int, lastname (no spaces))"
$Wwho = "*$who*"
$who = Get-ADUser -Filter {samaccountname -like $Wwho}
$men2= @()
$menu = @{}
for ($i=1;$i -le $who.count; $i++) {
    $men2 += New-Object PSObject -Property ([ordered]@{
            Accounts          = "$i. $($who[$i-1].name )" 
        })
     $menu.Add($i,($who[$i-1].samAccountName))
    }
$men2 | FT 
[int]$ans = Read-Host "`nEnter number to select user"
$selection = $menu.Item($ans) 

Get-ADUser $selection -Properties EmailAddress | select Name,EmailAddress,UserPrincipalName,Enabled | fl
pause
}'