Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WUList -WindowsUpdate

Get-WindowsUpdate -Install -AcceptAll -AutoReboot

Invoke-WUJob -ComputerName saeqdhcp01  -Script { Install-WindowsUpdate -AcceptAll -SendReport -IgnoreReboot } -Confirm:$false -verbose -RunNow