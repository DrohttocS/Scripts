$dcs = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }| Select-Object Name -ExpandProperty name | Sort-Object
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$session = New-PSSession -ComputerName $dcs -Credential $AdminCred

cls
Invoke-Command -Session $session -ScriptBlock {
    $Daysback = "-7"
    $Today = Get-Date
    $DeleteScope = $Today.AddDays($Daysback)
    $Log = "C:\temp\DNSLogCleanupLog.txt"
    $DNSlogfilepath = Get-DnsServerDiagnostics | Select-Object  LogFilePath -ExpandProperty LogFilePath
    $DNSlogpath = Split-Path -Path $DNSlogfilepath
    $dnslogs =  Get-ChildItem $DNSlogpath | Where-Object { $_.LastWriteTime -lt $DeleteScope } 
    $count = $dnslogs.count
    $raw = Get-ChildItem $DNSlogpath 
    $rawCount = $raw.count
    $cur = $rawCount - $count
    If(!(test-path "C:\temp")){New-Item -ItemType Directory -Force -Path "C:\temp"}
    $dnslogs |  Remove-Item -Force
    Write-Output $env:COMPUTERNAME
    Write-Output "Starting cleanup of DNS log files in $DNSlogpath" | Tee-Object $Log -Append
    Write-Output "Start time:" $StartTime | Out-File $Log -Append | Tee-Object $Log -Append
    Write-Output "Removed $count logs out of $rawCount Left $cur " | Tee-Object $Log -Append
    Write-Output "DNS log cleanup script completed." | Tee-Object $Log -Append
    Write-Output "End time: " $EndTime | Tee-Object $Log -Append
    Write-Output "####################################################" | Out-File $Log -Append
    Write-Output "####################################################" | Out-File $Log -Append 
}
Remove-PSSession $session