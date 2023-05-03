Clear-Host
$wshell = New-Object -Com "wscript.shell"
$i= -1
while($true)
{
$wshell.sendkeys("{SCrolllock}")
Start-Sleep -Milliseconds 100
$wshell.sendkeys("{SCrolllock}")
$i++;Clear-Host
write-host ($i * 5 ) "minutes Hours:" ([math]::round((($i * 5)/60),2))
Start-Sleep -Seconds 300
}
