# Install-Module ADEssentials
# https://evotec.xyz/visually-display-active-directory-nested-group-membership-using-powershell/

Show-ADGroupMember -GroupName 'Domain Admins' -FilePath C:\temp\Domadmins.html 

Get-WinADGroupMemberOf -Identity admshord | ft


Show-WinADGroupMemberOf -Identity 'soularde' -Summary