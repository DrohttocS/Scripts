#----Install AD-Domain-Services Feature...
install-windowsfeature -name AD-Domain-Services -includemanagementtools | select-object -expandproperty featureresult | ft displayname,success,restartneeded -auto
install-addsdomaincontroller -domainname nidecds.com -credential (get-credential) -InstallDns:$true -databasepath "%systemroot%\ntds" -logpath "E:\ntds" -sysvolpath "%systemroot%\SYSVOL" -safemodeadministratorpassword (read-host -prompt "Password:" -assecurestring)


get-adobject -filter "objectcategory -eq 'computer'" -searchbase "ou=domain controllers,dc=nidecds,dc=com" -searchscope subtree -properties distinguishedname,useraccountcontrol|select distinguishedname,name,useraccountcontrol|where {$_.useraccountcontrol -ne 532480} | 
%{set-adobject -identity $_.distinguishedname -replace @{useraccountcontrol=532480} -Credential $AdminCred }

get-adobject -filter "objectcategory -eq 'computer'" -searchbase "ou=domain controllers,dc=nidecds,dc=com" -searchscope subtree -properties distinguishedname,useraccountcontrol|select distinguishedname,name,useraccountcontrol|where {$_.useraccountcontrol -ne 532480} 


<#Open administrative powershell.
Run net share
Review shares and find NETLOGON and SYSVOL shares, if they are there turn them off and back on in registry.
Type regedt32 in Powershell and edit the following registry entry
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters
Change sysvolready=0   <<<< Turns off sysvol and netlogon shares.
Change sysvolready=1   <<<< Creates and shares sysvol and netlogon automatically.
Do this to all Domain Controllers
#>