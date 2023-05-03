$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$ADPC = Get-ADComputer -Filter {(Enabled -eq $true) -and (OperatingSystem -notlike '*Server*') } -Properties * | sort
$broken = $ADPC | ?{ $_.Ipv4address -ne $null }  | sort IPv4Address;cls
$broken | group OperatingSystemVersion | select Count, name

$broken |select name,IPv4Address |sort IPv4Address



$upd = $broken | ?{($_.OperatingSystemVersion -ne "10.0 (19042)") -and ($_.OperatingSystemVersion -ne "6.1 (7601)") -and ($_.OperatingSystemVersion -ne "10.0 (19043)")} | select name,IPv4Address |sort IPv4Address

$upd.Count
$isup=@()
$isDown=@()
cls
$upd.name | ForEach {

        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
         
            write-Host "$_ is alive and Pinging " -ForegroundColor Green 
            $isup += Get-ADComputer -Identity $_ -Properties *
         
                    } else 
                     
                    { Write-Warning "$_ Not online or accessable"
             $isDown += $_
                    }     
         
}

$isup |select name,IPv4Address,OperatingSystemVersion |sort IPv4Address 


"MMS-TLR01X-0919","ABB-ESTOKE-0120","ABB-ITM01-1219","LLO-HL6PR33","LLO-CFUGE-0620","LLO-ITM01-0120","LLO-DDVC613","LLO-MRPIT-0919","LLO-VDESK04","LLO-ABRAD-1119","MDB-NACT02-0120","MMS-ITM02-0519","MMS-DSAND-0819","MMS-ITM03-1219","LAPTOP-2903584","DESKTOP-ORS8ETF","DESKTOP-0W6NKUB","DESKTOP-2Q14FOA","BON-PROOF-0920","BON-TLR02-0418","BON-DESKTP-0120","BON-TLR03-0120","BON-NACT01-1218","BON-NACT03-0719","MDB-TLR02-1117","FRN-TLR04-1019","FRN-BCLAR-0319","KAL-TLR01-1019","MBW-TLR01-0116","MBW-NACT01-0120","MBW-TLR02-0116","MBW-NACT02-0120"


$broken = $broken.name 
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"



Start-Sleep -Seconds 900

Invoke-Command -Session $str {
New-SmbMapping -LocalPath 'X:' -RemotePath "\\192.168.100.12\" -UserName admin -Password 0OQbbsgft3dNQZj
X:
.\setup.exe  /auto upgrade /quiet /noreboot
}

$res = Invoke-Command -Session $str {Get-Process setup*} -ErrorAction SilentlyContinue
$res | Select-Object PSComputerName,ProcessName |sort PSComputerName -Unique
$res = $res.PSComputerName | sort -Unique
$res.Count

$bon =   New-PSSession -Credential $AdminCred  -ComputerName "BON-PROOF-0920","BON-TLR02-0418","BON-DESKTP-0120","BON-TLR03-0120","BON-NACT01-1218","BON-NACT03-0719"


Invoke-Command -Session $str {
shutdown /r /f /t 32400
}


$res = Invoke-Command -Session $new {Get-Date} -ErrorAction SilentlyContinue
$res | Select-Object PSComputerName,ProcessName 
$res = $res.PSComputerName | sort -Unique
$res.Count


Invoke-Command -Session $bon {Get-SmbShare -Special $false} -ErrorAction SilentlyContinue

Invoke-Command -Session $s {
Restart-Computer
}

Invoke-Command -Session $bon {
[System.Environment]::OSVersion.Version
}
Get-PSSession | Remove-PSSession
