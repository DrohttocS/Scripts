$dcs = "QNGCNNDSVPDC01.nidecds.com"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$inst=@();$c1 = 0

foreach($srv in $dcs){
$c1++
Write-Progress -Id 0 -Activity 'Checking servers' -Status "Processing $($c1) of $($dcs.count)" -CurrentOperation $computer -PercentComplete (($c1/$dcs.Count) * 100)
$installed = Get-WindowsFeature -ComputerName $srv -Credential $AdminCred | ? { $_.Installed -and $_.depth -eq "1"-and $_.NAME -notlike "Net*" -and $_.NAME -notlike "powershell*" -and $_.NAME -notlike "rsat*" -and $_.NAME -notlike "windows-*" -and $_.NAME -notlike "telnet*" -and $_.NAME -notlike "wow64*" -and $_.NAME -notlike "nfs*"}
$inst += ForEach ($Feature in $installed){
    [PSCustomObject]@{
    Hostname = $srv
    DisplayName = $feature.DisplayName
    Name = $feature.name
    }#EndPSCustomObject
}#EndForEach

}
$inst 



