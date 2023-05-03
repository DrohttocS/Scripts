$VulScan = Import-Csv -Path 'C:\Temp\Scheduled Report - Weekly Server High Severity Report - Includes QID Exclusions-2022-11-18 130210.csv'
$VulScan | Out-GridView

$silverlight = $VulScan | ?{$_.title -match "Silverlight"} | select -ExpandProperty netBios
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"



$session = New-PSSession -ComputerName $silverlight -Credential $AdminCred

$res = Invoke-Command -Session $session -ScriptBlock {

Get-ChildItem -Path HKLM:\SOFTWARE\icrosoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "silver" } | Select-Object -Property DisplayName, UninstallString

$SivLite = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -like "*SilverLight*"}
$SivLite.Uninstall()

}

$res

Invoke-Command -ComputerName $silverlight -Credential $AdminCred `
   -ScriptBlock {
      $product = Get-WmiObject win32_product | where{$_.name -match "SilverLight"}
      $product.IdentifyingNumber
      Start-Process "C:\Windows\System32\msiexec.exe" `
      -ArgumentList "/x $($product.IdentifyingNumber) /quiet /noreboot" -Wait
   }
$SL = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "silverlight" } | Select-Object -ExpandProperty UninstallString
$cmd = "C:\Windows\System32\"+$SL+" /quiet /noreboot"
$cmd
#Start-Process   $cmd  -Wait
