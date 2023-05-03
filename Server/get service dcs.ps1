$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs
$res = Invoke-Command -Session $session {Get-Service -Name Spooler | Set-Service -Status Stopped -StartupType Disabled}