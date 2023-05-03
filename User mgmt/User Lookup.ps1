invoke-expression 'cmd /c start powershell -Command {
$who = Read-host "Who are we searching for"
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
$men2 | ft
[int]$ans = Read-Host "`nEnter the Number of user you want"
$selection = $menu.Item($ans) 

Get-ADUser $selection -Properties EmailAddress | select Name,EmailAddress,UserPrincipalName,Enabled | fl
pause
}'