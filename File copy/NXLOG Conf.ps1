$servers = Get-ADComputer -Filter{OperatingSystem -like "*Server*"} | Select-Object -ExpandProperty name
$winrm = foreach($srv in $servers){Test-NetConnection -ComputerName $srv -CommonTCPPort WINRM}
$UP = $winrm |Where-Object {$_.TcpTestSucceeded -eq $true} | Select-Object -ExpandProperty ComputerName ;$down = $winrm |Where-Object {$_.TcpTestSucceeded -eq $false} | Select-Object -ExpandProperty ComputerName 


$nonDC = $UP | Where-Object{$_ -notlike "*dc*"}
$DC = $UP | Where-Object{$_ -like "*dc*"}
$tsvr = "SASPDB01"
$tses = New-PSSession $DC -Credential $AdminCred


$local = "C:\Temp\nxlogconf\nxlog-dns.conf"
$dest = "C:\Program Files (x86)\nxlog\conf\nxlog.new"


foreach($ses in $tses){
Copy-Item -ToSession $ses $local -Destination $dest -Force
}


Invoke-Command -Session $tses -ScriptBlock{

$dest = "C:\Program Files (x86)\nxlog\conf\nxlog.conf"
$backup = "C:\Program Files (x86)\nxlog\conf\nxlog.conf.old"
$newConf = "C:\Program Files (x86)\nxlog\conf\nxlog.new"

  If ((Test-Path $dest)){
    Write-host -f Green "$env:COMPUTERNAME has an NX file"
    Rename-Item $dest $backup}
    
    ElseIf((Test-Path $newConf)){Rename-Item $newConf $dest}
    restart-Service -Name nxlog 
    get-service -name nxlog
}



SAEQWDS01
NSHVIEPRDSQL01