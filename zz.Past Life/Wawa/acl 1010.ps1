
$domain = "DC=WAWA,DC=com"
$user = (Read-Host "Enter login name of user");

get-adobject -SearchBase $domain -filter{SamAccountName -eq $user} -IncludeDeletedObjects -properties IsDeleted,LastKnownParent | Select-Object Name,IsDeleted,LastKnownParent,DistinguishedName

$SecGroups.Count
$SecGroups = Get-ADGroup -Filter {GroupCategory -eq "Security" } -Properties admincount,extensionAttribute1, extensionAttribute2 | ?{$_.extensionAttribute2 -ge 0 -or $_.extensionAttribute1 -ge 0  } | select name,extensionAttribute1, extensionAttribute2,DistinguishedName ,admincount
$SecGroups.Count


$extattrib = $SecGroups | ?{$_.extensionAttribute2 -ge 0 -or $_.extensionAttribute1 -ge 0  } | select name,extensionAttribute1, extensionAttribute2,DistinguishedName ,admincount
$extattrib | Select-Object name,extensionAttribute1, extensionAttribute2,DistinguishedName,admincount |sort DistinguishedName | ft -AutoSize -Wrap
$extattrib | Select-Object name,extensionAttribute1, extensionAttribute2,DistinguishedName,admincount |sort DistinguishedName | Export-Csv -NoTypeInformation -Path C:\Temp\extattribGroups.csv


$extattrib | select name,extensionAttribute1, extensionAttribute2,DistinguishedName,admincount| ?{$_.admincount -eq 1} | ft -AutoSize -Wrap



$cp = (Get-Acl "ad:$((Get-ADGroup -Identity $extattrib[0].name).distinguishedname)").access | Select IdentityReference,AccessControlType,ActiveDirectoryRights | sort IdentityReference 

$cp | Export-Csv -Path C:\Temp\acl.txt -NoTypeInformation

C:\Temp\acl.txt

#SDDL
$GRoupacl = (Get-Acl "ad:$((Get-ADGroup -Identity $extattrib[0].name).distinguishedname)")
$sddl = 

$sdrights = ConvertFrom-SddlString -Sddl $GRoupacl.Sddl -Type ActiveDirectoryRights | Select-Object -ExpandProperty DiscretionaryAcl
$sdrights| out-String |Export-Csv -Path C:\Temp\SDDL.csv -NoTypeInformation -Delimiter ':'


#Groups of note
$SecGroups = Get-ADGroup -Filter {GroupCategory -eq "Security" } -Properties admincount,extensionAttribute1, extensionAttribute2 | ?{$_.extensionAttribute2 -ge 0 -or $_.extensionAttribute1 -ge 0  } | select name,extensionAttribute1, extensionAttribute2,DistinguishedName ,admincount
#SDadminHolders - Admin count of 1 
$extattrib = $SecGroups | select name,extensionAttribute1, extensionAttribute2,DistinguishedName,admincount| ?{$_.admincount -eq 1}|Out-GridView # | ft -AutoSize -Wrap
#Permission Template
$cp = (Get-Acl "ad:$((Get-ADGroup -Identity $extattrib[0].name).distinguishedname)").access | Select IdentityReference,AccessControlType,ActiveDirectoryRights | sort IdentityReference 
$cp | Export-Csv -Path C:\Temp\acl.csv -NoTypeInformation
$cp | Out-File  C:\Temp\acl.txt ; C:\Temp\acl.txt

