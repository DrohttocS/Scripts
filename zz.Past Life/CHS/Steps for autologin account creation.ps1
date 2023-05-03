

If (!(Test-Path chs:))
{
   import-module activedirectory
   New-PSDrive -Name chs -PSProvider ActiveDirectory -Server "chsdc01.chsspokane.local" -Scope Global -credential (Get-Credential "chsspokane\hords") -root "//RootDSE/"
    Set-Location chs:
}
$CloneAC = Read-Host "Autologon to copy "
$user2copy = Get-ADUser -identity $CloneAC
$pcname = Read-Host "Autologon to build "
$pcname = $pcname.ToUpper()
$passwd = $pcname -replace "-", ""
$passwd = $passwd.ToLower()
New-ADUser -Name "$pcname" -GivenName "$pcname" -SamAccountName "$pcname" -DisplayName "$pcname" -LogonWorkstations "$pcname" -AccountPassword (ConvertTo-SecureString "$passwd" -AsPlainText -Force) -Description "DMC - Auto Login for $pcname" -Path "OU=Autologons,OU=DMC,DC=chsspokane,DC=local" -scriptPath "login.bat" -CannotChangePassword $true -PasswordNeverExpires $true -Instance $user2copy -UserPrincipalName "$pcname"
$CopyFromUser = Get-ADUser $user2copy -prop MemberOf
$CopyToUser = Get-ADUser $pcname -prop MemberOf
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
 