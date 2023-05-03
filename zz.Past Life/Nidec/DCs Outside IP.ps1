$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$session = New-PSSession  -ComputerName $dcs

$res=@()
$res =  Invoke-Command -Session $session -ScriptBlock {

try{
        $dcinfo = Get-ADDomainController $env:COMPUTERNAME
        $keyPath = 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
        if (!(Test-Path $keyPath)) { New-Item $keyPath -Force | Out-Null }
        Set-ItemProperty -Path $keyPath -Name "DisableFirstRunCustomize" -Value 2

            $Outside = Invoke-RestMethod -Uri ('http://ipinfo.io/'+(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)

         New-Object PSObject -Property ([ordered]@{
                    Identity          = $ENV:COMPUTERNAME
                    'AD Site'         = $dcinfo.Site
                    'Local IP'         = $dcinfo.IPv4Address
                    'Outside IP'      = $Outside.ip
                    City              = $Outside.city
                    Region            = $Outside.region
                    Country           = $Outside.Country
                    ISP               = $Outside.org
                })
         

}
Catch{
       Write-Warning "Could not access $ENV:COMPUTERNAME"

         New-Object PSObject -Property ([ordered]@{
                    Identity          = $ENV:COMPUTERNAME
                    'AD Site'         = $dcinfo.Site
                    'Local IP'         = $dcinfo.IPv4Address
                    'Outside IP'      = 'Blocked'
                    City              = 'N/A'
                    Region            = 'N/A'
                    Country           = 'N/A'
                    ISP               = 'N/A'
                })
Continue
}
}









$res |select Identity,'AD Site','Local IP','Outside IP',City,Region,Country,ISP | Export-Csv -NoTypeInformation -Path C:\temp\outsideIPs.csv

Remove-PSSession $session