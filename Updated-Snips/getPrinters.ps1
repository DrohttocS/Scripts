$Computer = "D-PBXPC008"
#Read-host $Computer = 'Name'

#Get Local Printers:
$Printers = @(Get-WmiObject win32_printer -computername $Computer -Impersonation 3 -Credential CHSspokane\hords | select Name)
$Prname = $objItem.Name
#Get List of Network Printers:
#$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('currentuser', $Computer)
#$RegKey= $Reg.OpenSubKey('Printers\Settings')
#$Printers += @($RegKey.GetValueNames())

#Output List of Printers
#Write-Output $Printers | ft -Property @{Name="Printer Name";Expression={$_.Name}} -AutoSize
#Write-Output $Printers | Where-Object {$_.Name -notlike 'Microsoft*'} > \\dc2\dvsupport\Temp\WIN7MIG\$Computer.txt
#Write-Output $Printers > \\dc2\dvsupport\Temp\WIN7MIG\P-

$out = $Printers Where-Object {$_.Name -notlike 'Microsoft*'}

Write-Output $out 

#Get Default Printer
#$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('currentuser', $Computer)
#$RegKey= $Reg.OpenSubKey('Software\Microsoft\Windows NT\CurrentVersion\Windows')
#$DefaultPrinter = $RegKey.GetValue("Device")

#Output the Default Printer
#Write-Output $DefaultPrinter | ConvertFrom-Csv -Header Name, Provider, Order| Select Name | ft -Property @{Name="Default Printer Name";Expression={$_.Name}} -AutoSize