$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$ISECred = Get-StoredCredential -Target "$env:USERNAME-ise"
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$div ='+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+'
$men2= @()
$menu = @{}
for ($i=1;$i -le $dcs.count; $i++) {
  # Write-Host "$i. $($dcs[$i-1].name )" -ForegroundColor Green
    $men2 += New-Object PSObject -Property ([ordered]@{
            TheThing          = "$i. $($dcs[$i-1].name )" 
        })
     $menu.Add($i,($dcs[$i-1].name))
    }

$men2 | Format-Wide -Column 4 -Force

[int]$ans = Read-Host "`nEnter selection"
$selection = $menu.Item($ans) 

$res = Invoke-Command -ComputerName $selection -Credential $AdminCred -ScriptBlock{

Get-DnsServerForwarder

}  
$res