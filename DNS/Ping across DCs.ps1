$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs
cls
$HostToPing = Read-Host "Who are we looking up"
$res = Invoke-Command -Session $session -ScriptBlock {Resolve-DnsName -Name $using:HostToPing -ErrorAction SilentlyContinue}

$dccount = $session.Count
Write-Host "`n Checking $HostToPing's Name resoultion on $dccount DC's."
$res | group IPAddress | select count, name


Remove-PSSession $session
$res | ft



