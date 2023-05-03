$dcs = Read-Host "Name of new DC "
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
#$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs
 Enter-PSSession -ComputerName $dcs -Credential $AdminCred


Get-DnsServerDiagnostics
# Set-DNSServerDiagnostics -EnableLogFileRollover $true 


$DNSDL = 'E'# Get-volume |? {$_.SizeRemaining -gt 1} | sort SizeRemaining -Descending |select Driveletter -First 1 -ExpandProperty Driveletter
$lfp = $DNSDL + ':\DNSLogs'


If(!(test-path $lfp)){
New-Item -ItemType Directory -Force -Path $lfp
Set-DnsServerDiagnostics -LogFilePath "$lfp\DNS.logs"}


Set-DnsServerDiagnostics -Queries $true -Answers $true -Notifications $false -Updates $false -QuestionTransactions $true -UnmatchedResponse $true -SendPackets $true -ReceivePackets $true -TcpPackets $true -UdpPackets $true -FullPackets $false -EventLogLevel 7 -UseSystemEventLog $false -EnableLoggingToFile $true -EnableLogFileRollover $true -WriteThrough $false -EnableLoggingForLocalLookupEvent $true -EnableLoggingForPluginDllEvent $true -EnableLoggingForRecursiveLookupEvent $true -EnableLoggingForRemoteServerEvent $true -EnableLoggingForServerStartStopEvent $true -EnableLoggingForTombstoneEvent $true -EnableLoggingForZoneDataWriteEvent $true -EnableLoggingForZoneLoadingEvent $true
Get-Service -Name DNS | Stop-Service
Get-Service -Name DNS | Start-Service

New-SmbShare -Name "DnsLogs" -Path "$lfp" -Description "Rapid7 DNS logs"
Get-SmbShare
Exit-PSSession
