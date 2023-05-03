###################################
# Download and Install Sysmon
###################################
$url="https://download.sysinternals.com/files/Sysmon.zip"

New-Item -Path c:\Utils -ItemType directory
$output = "c:\Utils\sysmon.zip"
Import-Module BitsTransfer  
Start-BitsTransfer -Source $url -Destination $output
$ErrorActionPreference= 'silentlycontinue'
cd C:\Utils
$shell_app=new-object -com shell.application
$filename = "sysmon.zip"
$zip_file = $shell_app.namespace((Get-Location).Path + "\$filename")
$destination = $shell_app.namespace((Get-Location).Path)
$destination.Copyhere($zip_file.items())
.\Sysmon.exe -accepteula -i
.\Sysmon.exe -c -h md5 -n

 
 ###################################
# Set Event Audits
###################################
  $evt_SF =  "Sensitive Privilege Use","Security System Extension","System Integrity","IPsec Driver","Other System Events","Security State Change","Logon","Other Logon/Logoff Events","File System","Kernel Object","Certification Services","Application Generated","File Share","Sensitive Privilege Use","Process Termination","RPC Events","Process Creation","Audit Policy Change","Authorization Policy Change","User Account Management","Computer Account Management","Security Group Management","Distribution Group Management","Other Account Management Events","Directory Service Changes","Other Account Logon Events","Credential Validation"
  Foreach ($SF in $evt_SF){Write-Host "Setting aduit poliy on $SF"
                           auditpol.exe /set  /subcategory:"$SF" /failure:enable /success:enable}
  $evt_S = "Logoff","Account Lockout","Special Logon","Registry","Detailed File Share","Authentication Policy Change" 
  Foreach ($S in $evt_S){Write-Host "Setting aduit poliy on $S"
                         auditpol.exe /set /subcategory:"$S"  /failure:enable /success:enable}
#####################################
# Set time MST
####################################
tzutil.exe /s 'Mountain Standard Time'
#####################################
# Disable UAC
####################################
  function Disable-UserAccessControl {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000 -Force
    Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green    
}
#####################################
# Turn off IE Enhanced Security
####################################
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}
Disable-UserAccessControl
Disable-InternetExplorerESC
Limit-EventLog -LogName Application -MaximumSize 250112KB
Limit-EventLog -LogName Security -MaximumSize 500224KB
Limit-EventLog -LogName System -MaximumSize 250112KB
Limit-EventLog -LogName 'Windows PowerShell' -MaximumSize 250112KB
$maxfs = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational"
Set-ItemProperty -Path $maxfs -Name "MaxSize" -Value 250112 -Force -Type "dword"
############################
# Set Nic 
############################
$bindings="ms_tcpip6","ms_rspndr","ms_lltdio","ms_implat"
foreach ($binding in $bindings){Disable-NetAdapterBinding -Name "Ethernet" -ComponentID $binding}
###########################
# Turn Firewall Off
###########################
Set-NetFirewallProfile -Profile * -Enabled False
