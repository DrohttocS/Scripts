$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$pDNS = Get-DnsClientServerAddress -InterfaceAlias Ethernet | select ServerAddresses -ExpandProperty ServerAddresses
$pDNS = $pDNS[0] 
$pDNS = [System.Net.Dns]::GetHostByAddress($pDNS).HostName
$zoneName = "nidecds.com"
function Show-Menu {
    param (
        [string]$Title = 'DNS Stuff'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' Add single DNS A record."
    Write-Host "2: Press '2' for this option."
    Write-Host "3: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
         Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{

                Get-DnsServerZone

         }



    } '2' {
         'You chose option #2'
    } '3' {
        'You chose option #3'
    }
    }
    pause
 }
 until ($selection -eq 'q')
