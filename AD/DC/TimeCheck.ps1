$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort

$session = New-PSSession -Credential $AdminCred -ComputerName $dcs -EnableNetworkAccess 

$res = Invoke-Command -Session $session -ScriptBlock {
#w32tm /query /peers
$s = w32tm /query /source

New-Object PSObject -Property ([ordered]@{
            Identity          = $ENV:COMPUTERNAME
            Source = $s
            })
}
$res | select Identity,Source| sort Source | ft 

Remove-PSSession $session