#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$dcs = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ }| Select-Object Name -ExpandProperty name | Sort-Object
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs
$res = Invoke-Command -Session $session -ScriptBlock {Get-DnsServerDiagnostics}
$SRVS2Clean = $res | Select-Object  PSComputerName, LogFilePath |Sort-Object PSComputerName
$Daysback = "-30"
$Today = Get-Date
$DeleteScope = $Today.AddDays($Daysback)
$Log = "C:\temp\DNSLogCleanupLog.txt"
$StartTime = Get-Date
$EndTime = Get-Date
$paths=@()

ForEach ($srv in $SRVS2Clean){
    $dl = Split-Path -Path $srv.LogFilePath -Parent 
    $dl = $dl -replace ':','$'
    $dc =  "\\" + $srv.PSComputerName + "\" + $dl
  $paths +=  $dc
        }



$newobj
Write-Output "Starting cleanup of DNS log files on all DCs in domain at E:\DNS_Logs" | Out-File $Log -Append
Write-Output "Start time:" $StartTime | Out-File $Log -Append
ForEach ($path in $paths) {
    if (Test-Path -Path $path) {
        Get-ChildItem $path | Where-Object { $_.LastWriteTime -lt $DeleteScope } | Remove-Item
        Write-Output "$DCFQDN - DNS log cleanup completed" | Out-File $Log -Append
        try {
            $Disk = Get-DiskSize $DCFQDN | ? {$_.Name -eq 'E:\'}
            $Free = $Disk.FreeSpace
            Write-Output "E:\ free space is now $Free GB" | Out-File $Log -Append
        }
        catch { Write-Output "$DCFQDN - Could not get free space of E:\" | Out-file $Log -Append
        }
    }
    else { Write-Output "$DCFQDN - Path not found" | Out-file $Log -Append }
}
Write-Output "DNS log cleanup script completed." | Out-File $Log -Append
Write-Output "End time: " $EndTime | Out-File $Log -Append
Write-Output "####################################################" | Out-File $Log -Append
Write-Output "####################################################" | Out-File $Log -Append