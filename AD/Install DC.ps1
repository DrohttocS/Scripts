#----Install AD-Domain-Services Feature...
install-windowsfeature -name AD-Domain-Services -includemanagementtools | select-object -expandproperty featureresult | ft displayname,success,restartneeded -auto
install-addsdomaincontroller -domainname nidecds.com -credential (get-credential) -InstallDns:$true -databasepath "%systemroot%\ntds" -logpath "E:\ntds" -sysvolpath "%systemroot%\SYSVOL" -safemodeadministratorpassword (read-host -prompt "Password:" -assecurestring)


get-adobject -filter "objectcategory -eq 'computer'" -searchbase "ou=domain controllers,dc=nidecds,dc=com" -searchscope subtree -properties distinguishedname,useraccountcontrol|select distinguishedname,name,useraccountcontrol|where {$_.useraccountcontrol -ne 532480} | 
%{set-adobject -identity $_.distinguishedname -replace @{useraccountcontrol=532480} }



Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-CriticalReplicationOnly:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainName "nidecds.com" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SiteName "US-LEX-01" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

