$dhcpsrv = Get-DhcpServerInDC | sort Ipaddress | select -ExpandProperty DnsName
$isup=@();$isDown=@()
$dhcpsrv| ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            write-Host "$_ is alive and Pinging " -ForegroundColor Green
             $isup += $_
                    } else 
                    { Write-Warning "$_ Not online or accessable"
             $isDown += $_
                    }     
                 } 

#          $isup = "amrndsvpdh03"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$isup.Count;$isDown.Count


foreach($srv in $isup){
$fpath = "C:\Temp\"+$srv+"_dhcpexport.xml"
Invoke-Command -ComputerName $srv -Credential $AdminCred -ScriptBlock{
$dhcpexport = "c:\users\"+"$env:USERNAME"+"\Documents\"+"$env:COMPUTERNAME"+"_DHCP_export.xml"

Remove-Item -Path $dhcpexport -ea SilentlyContinue
Export-DhcpServer -ComputerName $env:COMPUTERNAME  -File $dhcpexport
gc -Path $dhcpexport
Remove-Item -Path $dhcpexport -ea SilentlyContinue
} | Out-File -FilePath $fpath
}

$audit =@()
foreach($srv in $isup){

$audit += Invoke-Command  -ComputerName $srv -Credential $AdminCred -ScriptBlock {
Get-DhcpServerAuditLog 
}
}