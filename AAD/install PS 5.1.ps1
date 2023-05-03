
$versionCheck = $PSVersionTable.PSVersion.Major
If($versionCheck -lt 5){
$url = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"
$outpath = "C:\temp\psinstall.msu"
Invoke-WebRequest -Uri $url -OutFile $outpath
wusa.exe $outpath /quiet /norestart
}

Function get-PSVersion{
   $versionCheck = $PSVersionTable.PSVersion.Major
   $psvt = $PSVersionTable.PSVersion | Out-String
# If old
 $remstat = Test-Path -Path "C:\temp\psinstall.msu"
    
    If($remstat -eq $false -and $versionCheck -lt 5){
    Write-Host $env:COMPUTERNAME "Need Things Downloading and installing PS 5"
        If($versionCheck -lt 5){
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            
            $url = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu"
            $outpath = "C:\temp\psinstall.msu"
            Invoke-WebRequest -Uri $url -OutFile $outpath
                if (!(Test-Path C:\windows\SysWOW64\wusa.exe)){
                      $Wus = 'C:\windows\System32\wusa.exe'
                    }
                    else {
                      $Wus = 'C:\windows\SysWOW64\wusa.exe'
                    }
            Write-Host "Wus = $Wus"
             Start-Process -FilePath $wus -ArgumentList "C:\temp\psinstall.msu" /quiet /norestart" -Wait


       }

    }
    Elseif($remstat -eq $true -and $versionCheck -lt 5){
    Write-host $env:COMPUTERNAME "Has been Patched and needs a reboot"
    }
    else{Write-host $env:COMPUTERNAME "Nothing to do here.`n$psvt"}
}

 Invoke-Command -ComputerName $srvs -Credential $AdminCred -ScriptBlock ${function:get-PSVersion}
