

$dcs = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }| Select-Object Name -ExpandProperty name | Sort-Object
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs -ErrorAction SilentlyContinue

$results = Invoke-Command -Session $session -ScriptBlock {
$Daysback = "-15"
$Today = Get-Date
$DeleteScope = $Today.AddDays($Daysback)
$Log = "C:\temp\DNSLogCleanupLog.txt"
$logfilepath = Get-DnsServerDiagnostics | Select-Object  LogFilePath -ExpandProperty LogFilePath
$logpath = Split-Path -Path $logfilepath
$dnslogs =  Get-ChildItem $logpath | Where-Object { $_.LastWriteTime -lt $DeleteScope } 
$count = $dnslogs.count
$raw = Get-ChildItem $logpath 
$rawCount = $raw.count
$cur = $rawCount - $count
$cur
$dnslogs |  Remove-Item
Write-Output "Starting cleanup of DNS log files in $logpath" | Tee-Object $Log -Append
Write-Output "Start time:" $StartTime | Out-File $Log -Append | Tee-Object $Log -Append
Write-Output "Removed $count logs out of $rawCount Left $cur " | Tee-Object $Log -Append
Write-Output "DNS log cleanup script completed." | Tee-Object $Log -Append
Write-Output "End time: " $EndTime | Tee-Object $Log -Append
Write-Output "####################################################" | Out-File $Log -Append
Write-Output "####################################################" | Out-File $Log -Append 
}

$results


Remove-PSSession $session