#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$locked = Search-ADAccount -lockedout  | Select-Object Name, SamAccountName | sort name

$men2= @()
$menu = @{}
for ($i=1;$i -le $Locked.count; $i++) {
    $men2 += New-Object PSObject -Property ([ordered]@{
            'Locked Accounts'          = "$i. $($Locked[$i-1].name )" 
        })
     $menu.Add($i,($Locked[$i-1].samAccountName))
    }
$men2 | Format-Wide -Column 2 -Force 

[int]$ans = Read-Host "`nEnter selection"
$selection = $menu.Item($ans) 
Unlock-ADAccount -Identity $selection -Credential $AdminCred



