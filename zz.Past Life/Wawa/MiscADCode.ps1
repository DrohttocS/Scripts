

#Get empty groups for all domains in forest
$domains = Get-ADForest | select -ExpandProperty domains
     $empties = @()
     $oops = @()
foreach ($d in $domains)
{
	$groups = get-adgroup -filter * -server $d -prop *
	foreach ($g in $groups)
	{
		$q = get-adgroup $g -properties members  | select -expandproperty members
		If (!$?)
		{
			$oops += $g
			write-host $g.name
		}
		if ($q -eq $null) { $empties += $g }
	}
}
#More Simple, single domain


#region Group Policy Inheritance
#To get a list of OUs and the status of GPO inheritance:
Get-ADOrganizationalUnit -SearchBase "OU=Servers,DC=domain,DC=tld" -Filter * | ft DistinguishedName, @{ Name = "Inheritance"; Expression = { (Get-GPInheritance$_.DistinguishedName).GpoInheritanceBlocked } } -Autosize
#To get a list of OUs that have GPO inheritance blocked:#
Get-ADOrganizationalUnit -SearchBase "OU=Servers,DC=domain,DC=tld" -Filter * | ?{ (Get-GPInheritance $_.DistinguishedName).GpoInheritanceBlocked -eq "Yes" } | ft DistinguishedName
#To get a list of OUs that have GPO inheritance blocked and a don't have a particular GPO applied to them directly:
Get-ADOrganizationalUnit -SearchBase "OU=Servers,DC=domain,DC=tld" -Filter * | ?{(Get-GPInheritance $_.DistinguishedName).GpoInheritanceBlocked -eq "Yes"} | ft DistinguishedName,@{Name="Linked?";Expression={if (((Get-GPInheritance $_.DistinguishedName).GpoLinks | select DisplayName) -match "GPO I am Interested In") { "Yes" } else { "No" }}} -AutoSize
c#endregion Group Policy Inheritance


#Get Disabled Accounts
$dd = Search-ADAccount -AccountDisabled
$dd.count
$dd1 = $dd | ?{ $_.objectclass -eq "user" }
$Dusers = @()
foreach ($d in $dd1) { $Dusers += (get-aduser $d.samaccountname -Properties enabled, proxyaddresses) }
$dusers.count
$userstodel = $dusers | ?{ $_.proxyaddresses.count -eq 0 }
$userstodelwithemailaddy = $dusers | ?{ $_.proxyaddresses.count -ne 0 }
$userstodelwithemailaddy = $userstodelwithemailaddy | ?{ $_.distinguishedname -notmatch "OU=SharedMailbox" }



#OU Permissions
$Results = @()
$OUS = Get-ADOrganizationalUnit -filter * -prop *

Foreach ($OU in $OUs)
{
	$ACLS = (Get-Acl "AD:$ou").access
	$notinherited = $ACLS | ?{ $_.isinherited -eq $false }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "NT AUTHORITY\ENTERPRISE DOMAIN CONTROLLERS" }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "NT AUTHORITY\Authenticated Users" }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "NT AUTHORITY\SYSTEM" }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "S-1-5-32-548" }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "S-1-5-32-550" }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "CORPORATE\Domain Admins" }
	$notinherited = $notinherited | ?{ $_.IdentityReference -ne "STORES\Domain Admins" }
	foreach ($ni in $notinherited)
	
	{
		$Results += "$OU;$($ni.AccessControlType);$($ni.IdentityReference);$($ni.ActiveDirectoryRights)"
	}
}

#Fix Group subobjects without inheriting permissions
$adgroups = Get-ADGroup -Filter * -SearchBase "OU=RBAC, DC=stores, DC=local"
$badgroups = @()
ForEach ($adgroup in $adgroups)
{
	$ACL = Get-Acl -Path "AD:\$($adgroup.distinguishedname)"
	If ($ACL.AreAccessRulesProtected)
	{
		$badgroups += $adgroup
		$ACL.SetAccessRuleProtection($False, $True)
		Set-ACL -AclObject $ACL -path "AD:\$($adgroup.distinguishedname)"
		$adgroup.name
	}
}


#Fix USer subobjects without inheriting permissions
$adusers = Get-ADUser -Filter * -SearchBase "OU=AlluserAccounts, DC=stores, DC=local"
$badusers = @()
ForEach ($aduser in $adusers)
{
	$ACL = Get-Acl -Path "AD:\$($aduser.distinguishedname)"
	If ($ACL.AreAccessRulesProtected)
	{
		$badusers += $aduser
		#$ACL.SetAccessRuleProtection($False, $True)
		#Set-ACL -AclObject $ACL -path "AD:\$($aduser.distinguishedname)"
		$aduser.name
	}
}

ForEach ($aduser in $realbad)
{
	$ACL = Get-Acl -Path "AD:\$($aduser.distinguishedname)"
	If ($ACL.AreAccessRulesProtected)
	{
		$ACL.SetAccessRuleProtection($False, $True)
		Set-ACL -AclObject $ACL -path "AD:\$($aduser.distinguishedname)" 
		$aduser.name
	}
}



#Set User Subobjects to inherit permissions
$adusers = Get-ADUser -Filter * -SearchBase "OU=Corporate, OU=AllUserAccounts, DC=stores, DC=local"
$users = @()
ForEach ($aduser in $adusers)
{
	$ACL = Get-Acl -Path "AD:\$($aduser.distinguishedname)"
	If ($ACL.AreAccessRulesProtected)
	{
		$ACL.SetAccessRuleProtection($False, $True)
		Set-ACL -AclObject $ACL -path "AD:\$($aduser.distinguishedname)"
		$aduser.name
	}
}


Function Set-Inheritance
{
	param ($ObjectPath)
	$ACL = Get-ACL -path "AD:\$ObjectPath"
	If ($acl.AreAccessRulesProtected)
	{
		$ACL.SetAccessRuleProtection($False, $True)
		Set-ACL -AclObject $ACL -path "AD:\$ObjectPath"
		Write-Host "MODIFIED "$ObjectPath
	} #End IF
} #End Function Set-Inheritance




#Find user with AdminCount set to 1
$users = get-aduser -SearchBase "OU=Managed Users,DC=Contoso,DC=com" -Filter { AdminCount -eq 1 }
#Enable inheritance flag for each user
$users | foreach { Set-Inheritance $_.distinguishedname }







#Is inheritence disabled
#  "AreAccessRulesProtected" resulsts in "True" if inheritance is *DISABLED*.  Otherwise False

$tou = Get-ADOrganizationalUnit "ou=Windows7_test,ou=Test-EndUser,DC=wawa,DC=com"
$tacl = get-acl $tou
$tacl.AreAccessRulesProtected


Foreach ($OU in $OUs)
{
	$acl = Get-Acl $OU
	If( $acl.AreAccessRulesProtected -eq $true){Write-Host $OU.name}
	
}


#Delete Stale Computers

$Complist = "owever you want to get list"

$shortlist = @()
foreach ($Comp in $Complist)
{
	$Cinfo = Get-ADComputer $Comp.name -Properties lastLogon,LastLogonDate
	If ($($Cinfo.lastlogondate) -lt "10/1/2019")
	{
		Write-Host "Deleted $($Comp.name) ----  $($Cinfo.lastlogondate)"
		$shortlist += $Cinfo.samaccountname
		Remove-ADComputer $($comp.name) -Confirm:$false
	}
	
}

function GetNestedADGroupMembership
{
	Param ([parameter(Mandatory = $true)]
		$user,
		[parameter(Mandatory = $false)]
		$grouphash = @{ })
	
	$groups = @(Get-ADPrincipalGroupMembership -Identity $user | select -ExpandProperty distinguishedname)
	foreach ($group in $groups)
	{
		if ($grouphash[$group] -eq $null)
		{
			$grouphash[$group] = $true
			$group
			GetNestedADGroupMembership $group $grouphash
		}
	}
}
function GetNestedADGroupMembership
{
	Param ([parameter(Mandatory = $true)]
		$user,
		[parameter(Mandatory = $false)]
		$grouphash = @{ })
	
	$groups = @(Get-ADPrincipalGroupMembership -Identity $user | select -ExpandProperty distinguishedname)
	foreach ($group in $groups)
	{
		if ($group -match "administrators")
		{
			$group
			$user
		}
		if ($grouphash[$group] -eq $null)
		{
			$grouphash[$group] = $true
			#$group
			GetNestedADGroupMembership $group $grouphash
		}
	}
}


#check Users for last logon - Build 2 lists
$recentlogon = @()
$norecentlogon = @()

foreach ($user in $chk)
{
	Get-ADUser $user -prop lastlogondate
	
}

#Check SA Users for associated standard user
$badusers = @()
foreach ($sa in $sas)
{
	$reguser = $null
	$username = $sa.samaccountname -replace "sa_", ""
	$reguser = Get-ADUser $username
	if ($reguser -eq $null)
	{
		$sa
		$badusers += $sa
	}
}

$badstoreusers = @()
$goodstoreusers = @()
foreach ($sa in $susers)
{
	$reguser = $null
	$username = $sa	
	$reguser = Get-ADUser $username
	if ($reguser -eq $null)
	{
		$sa
		$badstoreusers += $sa
	}
	else
	{
		$goodstoreusers += $sa
	}
}




#ServerAdmins Cleanup
$ServerAdmins = Get-ADGroupMember "ServerAdmin"
foreach ($ServerAdmin in $ServerAdmins)
{
	try
	{
		$sa = (Get-ADUser "SA_$($ServerAdmin.name)").name
	}
	catch { $sa = "xxx" }
	
	if ($sa -eq "xxx")
	{
		$NeedSA += $($ServerAdmin.name)
	}
	"$($ServerAdmin.name) - $sa"
	
	
}



#Create SA_Accounts

$Users = @()
foreach ($U in $ulist)
{
	$Users += Get-ADUser $U -prop *
	
}

Add-Type -AssemblyName System.Web
[System.Web.Security.Membership]::GeneratePassword(8, 3)

foreach ($user in $users)
{
	New-ADUser -name "SA_$($user.samaccountname)" -SamAccountName "SA_$($user.samaccountname)" -Description "Admin Account for $($user.samaccountname)" -GivenName $user.givenname`
			   -Surname $user.surname -AccountPassword (ConvertTo-SecureString -AsPlainText ([System.Web.Security.Membership]::GeneratePassword(12, 3)) -Force) `
			   -Path "OU=AdminAccounts,OU=Corporate Users,DC=WAWA,DC=com" -ChangePasswordAtLogon $true -Enabled $true `
		
}



$gusers = Get-ADGroupMember "PP_AlLAdminAccounts"
$users = @()
foreach ($s in $gusers) { $users += get-aduser $s.name }
$badlist = @()
foreach ($u in $users)
{
	try
	{
		$t = Get-ADUser ($u.name -replace "sa_", "" -replace "la_","") -prop *
		#Write-Host "$($u.name) - $($t.mail)"
		$newmail = $($t.mail) -replace "@wawa.com", ".admin@wawa.com"
		Write-Host $newmail
	}
	
	#Set-ADUser $u -Add @{extensionAttribute6="$"}
	catch
	{
		$badlist += $s.name
	
	}
}

New-Module
New-LocalUser

#ExtAttribute 10
$BadUser = @()
foreach ($user in $allusers)
{
	$JobCode = ($user.extensionattribute4 -split "PosGrp:")[1]
	$JobCode = ($JobCode -split ";")[0]
	If($JobCode -ne ""){
	$user.samaccountname
	Set-ADUser $User -Add @{ extensionAttribute10 = $jobcode }
	}
	else
	{
		$BadUser += $user
	}
}
New-ModuleNew-Module