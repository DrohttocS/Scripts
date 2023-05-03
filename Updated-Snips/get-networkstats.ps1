Enter-PSSession -ComputerName amrndsvscs02 -Credential $AdminCred
Enter-PSSession -ComputerName AMRNDSVSMV02 -Credential $AdminCred



$ses = New-PSSession "AMRNDSVSMV02","amrndsvscs02" -Credential $AdminCred

$a = Invoke-Command -Session $ses -ScriptBlock{

function Get-NetworkStatistics
{
 $properties = 'Protocol','LocalAddress','LocalPort'
 $properties += 'RemoteAddress','RemotePort','State','ProcessName','PID'

 netstat -ano |Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object {

 $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

 if($item[1] -notmatch '^\[::')
 {
 if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6')
 {
 $localAddress = $la.IPAddressToString
 $localPort = $item[1].split('\]:')[-1]
 }
 else
 {
 $localAddress = $item[1].split(':')[0]
 $localPort = $item[1].split(':')[-1]
 }

 if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6')
 {
 $remoteAddress = $ra.IPAddressToString
 $remotePort = $item[2].split('\]:')[-1]
 }
 else
 {
 $remoteAddress = $item[2].split(':')[0]
 $remotePort = $item[2].split(':')[-1]
 }

New-Object PSObject -Property @{
 PID = $item[-1]
 ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name
 Protocol = $item[0]
 LocalAddress = $localAddress
 LocalPort = $localPort
 RemoteAddress =$remoteAddress
 RemotePort = $remotePort
 State = if($item[0] -eq 'tcp') {$item[3]} else {$null}
 } |Select-Object -Property $properties
 }
 }
}

Get-NetworkStatistics |? {$_.remoteport -eq 2181 }| ft -AutoSize -Wrap
Get-NetworkStatistics |? {$_.localport -eq 2181 }| ft -AutoSize -Wrap
Get-NetworkStatistics |? {$_.State -eq "LISTENING" -or $_.state -eq "ESTABLISHED" }|sort ProcessName| ft -AutoSize -Wrap

Get-NetworkStatistics | sort processName | ft


}

Remove-PSSession $ses

Exit-PSSession