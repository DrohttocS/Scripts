<# 
Windows Time Sync Registry set up 
By allenage.com DC time sync v 0.1
Final Update on 6/19/2017


##########################****** Configuration Info *********####################################
# Peers
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NTPServer=pool.ntp.org,0x1
We are setting Pool.ntp.org,0x1 Check your region if you would set your own http://www.pool.ntp.org/zone/@

# interval
0x01 SpecialInterval
0x02 UseAsFallbackOnly
0x04 SymmetricActive
0x08 Client
0x9 which uses DNS round robin to make a random selection from a pool of time servers.


# For PDC Announce flag 5 and backup domain controllers
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\AnnounceFlags=5
This entry controls whether this computer is marked as a reliable time server. A computer is not marked as reliable unless it is also marked as a time server.
0x00 Not a time server
0x01 Always time server
0x02 Automatic time server
0x04 Always reliable time server
0x08 Automatic reliable time server
The default value for domain members is 10. The default value for stand-alone clients and servers is 10.

# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type=NTP
this entry indicates which peers to accept synchronization from:

NoSync. The time service does not synchronize with other sources.
NTP. The time service synchronizes from the servers specified in the NtpServer. registry entry.
NT5DS. The time service synchronizes from the domain hierarchy.
AllSync. The time service uses all the available synchronization mechanisms.

##########################****** Configuration Info *********####################################



Important psremoting needs to be enabled.

run  Enable-PSRemoting -Force on PowerShell elevated mode to enable Psremoting.

This script needs to be run as an administrator and it will modify registry.
The primary domain controller will sync time externally from pool.ntp.org while the secondary dc's will sync time from the primary (which has PDc emulator role.)

Later you can type Dcdiag to check Advertising test.

#> 

 
 If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
 {    
  Write-Host "This script needs to be run As Admin go back and Run as admin" -BackgroundColor red
Start-Sleep -Seconds 5
Exit
 }

Write-host "Enabling Psremoting on this Computer $env:computername" -ForegroundColor Green

Enable-PSRemoting -Force

import-module activedirectory

$pdc=Get-ADDomainController -Discover -Service PrimaryDC |select -ExpandProperty name
$PDCSYNC = { w32tm /config /manualpeerlist:"pool.ntp.org,0x1" /syncfromflags:manual /reliable:yes /update
w32tm /config /update
Restart-Service w32time
w32tm /resync /rediscover
w32tm /resync
}

# Registry Modifications for PDC so It advertise as Time server
$aflags={Set-ItemProperty -path "HKLM:\system\CurrentControlSet\Services\W32Time\Config" -Name AnnounceFlags -Value 5 -Type DWord -Force}
$ntp1={Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name Type -Value NTP  -Force }
$Vmic={Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider" -Name Enabled -Value 0 -Type DWord -Force}

Invoke-Command -ComputerName $pdc -ScriptBlock $PDCSYNC
Invoke-Command -ComputerName $pdc -ScriptBlock $aflags
Invoke-Command -ComputerName $pdc -ScriptBlock $ntp1
Invoke-Command -ComputerName $pdc -ScriptBlock $Vmic
$dc=Get-ADDomainController -filter * |?{$_.OperationMasterRoles -notcontains 'PDCEmulator'} |select -ExpandProperty name

# commands for DC to sync from primary
$dcupdate={w32tm /config /syncfromflags:domhier /update}
$advtest1={Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider" -Name Enabled -Value 0 -Type DWord -Force}
$advtest2={Set-ItemProperty -path "HKLM:\system\CurrentControlSet\Services\W32Time\Config" -Name AnnounceFlags -Value 10 -Type DWord -Force}
$ntp2={Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name Type -Value NT5DS  -Force }
$Advtest3={restart-service w32time}
$advtest4={w32tm /resync /rediscover}
$advtest5={w32tm /resync}
if($dc -like '*')
{
Invoke-Command -ComputerName $dc -ScriptBlock $dcupdate
Invoke-Command -ComputerName $dc -ScriptBlock $Advtest1
Invoke-Command -ComputerName $dc -ScriptBlock $Advtest2
Invoke-Command -ComputerName $dc -ScriptBlock $ntp2
Invoke-Command -ComputerName $dc -ScriptBlock $Advtest3
Invoke-Command -ComputerName $dc -ScriptBlock $Advtest4
Invoke-Command -ComputerName $dc -ScriptBlock $Advtest5
}
else

{
write-host "You have only one domain controller"
}