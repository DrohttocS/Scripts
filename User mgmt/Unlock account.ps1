#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$locked = Search-ADAccount -UsersOnly  -lockedout | where {$_.Enabled -eq $true}| Select-Object Name, SamAccountName | sort SamAccountName

$men2= @()
$menu = @{}
for ($i=1;$i -le $Locked.count; $i++) {
  # Write-Host "$i. $($Locked[$i-1].name )" -ForegroundColor Green
    $men2 += New-Object PSObject -Property ([ordered]@{
            'Locked Accounts'          = "$i. $($Locked[$i-1].name )" 
        })
     $menu.Add($i,($Locked[$i-1].samAccountName))
    }
$men2 | ft
[int]$ans = Read-Host "`nEnter selection"
$selection = $menu.Item($ans) 
Unlock-ADAccount -Identity $selection -Credential $AdminCred -PassThru 