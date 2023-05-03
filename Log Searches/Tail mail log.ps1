$path = 'C:\Program Files (x86)\hMailServer\Logs\'
$currentlog = gci $path | sort LastWriteTime | select -last 1
$log = "$path$currentlog"
Get-Content $log -wait
