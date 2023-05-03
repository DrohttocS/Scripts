<# 
Script Name:  GetMappedNetworkPrinters.ps1 
 
Purpose: 
This script can be used to collect the mapped network printer information from the users who are logged into the console of the Computer or Computers specified. 
 
Required Modules: 
PSRemoteRegistry, and Active Directory 
 
Permission Requirements: 
The user account that the script is run with needs to have administrative permissions on the workstations and permission to query Active Directory user accounts. 
The computers firewall if enabled needs to allow it to be pinged, connections to WMI and also Remote Registry. 
A user will need to be logged into the console so their mapped network printer information can be collected. 
 
How the script functions: 
Create a text file that contains a list of Computer names that you want to get the mapped network printers info for. 
Execute the script and you will be prompted for the path to the text file that contains the list. 
Connectivity will be verified to each of the computers by pinging each of them. 
Via WMI it will check to see which user is logged into the computers that responded to the ping. 
Next it will query Active Directory for the SID of each of the users that were currently logged into one of the active computers polled. 
Using the users SID a Remote Registry query is created to enumerate the list of mapped network printers for the logged on user. 
 
The Log files and CSV file containing the list of mapped printers is located in C:\temp\logs 
FileNames: 
MappedPrinters-(currentdate).csv -- Contains the list of mapped printers. 
NoMappedPrinters-(currentdate).log -- Contains list of users that do not have network printers mapped on their computer. 
NoReply-(currentdate).csv -- Contains list of computers that did not respond to ping. 
NoUsrLoggedIn-(currentdate).log -- Contains list of computers that responded to ping but did not have a user logged into it. 
RemoteRegNotRunning-(currentdate).log -- Contains a list of computers where the Remote Registry service is not running. 
WmiError-(currentdate).log -- If there are computers that it is not able to connect to via wmi it will be listed here. 
#> 
 
 
 
function global:Ping-Host {  
    BEGIN { 
         
    } 
        PROCESS { 
        $results = gwmi -Query "SELECT * FROM Win32_PingStatus WHERE Address = '$_'" 
        $obj2 = New-Object psobject 
        $obj2 | Add-Member Noteproperty Computer $_ 
        $obj2 | Add-Member Noteproperty IPAddress ($results.protocoladdress) 
                 
        if ($results.statuscode -eq 0) { 
        $obj2 | Add-Member NoteProperty Responding $True 
        } else { 
        $obj2 | Add-Member NoteProperty Responding $False 
    } 
        Write-Output $obj2 
         
    } 
    END {} 
     
} 
function VerifyConnectivity { 
param ( 
[parameter(ValueFromPipeline=$true)] 
$compList 
) 
BEGIN { 
$modeMSG = "Verifying Connectivity to Desktops" 
$HostComputer = @() 
$d = Get-Date 
$strDate = $d.ToString() 
$month = $d.Month 
$day = $d.Day 
$year = $d.Year 
$cDate = "$month-$day-$year" 
$logFilePath = "C:\temp\logs\" 
$NoReplyLog = $logFilePath + "NoReply-" + $cDate + ".csv" 
} 
PROCESS { 
$i = 1 
$numComp = $compList.Count 
If ($numComp -ge 1){ 
Talk $modeMSG 
$HostComputer = $HostComputer + $( 
    foreach ($computer in $compList){ 
    Write-Progress -Activity $modeMSG -Status "Currently Processing: $computer" -CurrentOperation "$i of $numComp" -PercentComplete ($i/$numComp*100) 
    $computer | Ping-Host 
    $i = $i + 1 
 
}) 
 
} 
ElseIf ($numComp -lt 1){ 
Write-Host "No Computers to Process" 
Exit 
} 
} 
END { 
$Alive = $HostComputer | Where {$_.Responding -eq "$true"} 
$global:Dead = $HostComputer | Where {$_.Responding -ne "$true"} 
$global:Dead | select Computer | Export-Csv -Path $NoReplyLog 
$Acomp = $Alive | select Computer 
$Acomp 
} 
 
} 
 
function GetPrinterInfo { 
param ( 
[parameter(ValueFromPipeline=$true)] 
$compList 
) 
BEGIN { 
$d = Get-Date 
$strDate = $d.ToString() 
$month = $d.Month 
$day = $d.Day 
$year = $d.Year 
$cDate = "$month-$day-$year" 
$global:logFilePath = "C:\temp\logs\" 
$NoPrtMapLog = $logFilePath + "NoMappedPrinters-" + $cDate + ".log" 
$WmiErrorLog = $logFilePath + "WmiError-" + $cDate + ".log" 
$MappedPrinters = $logFilePath + "MappedPrinters-" + $cDate + ".csv" 
$NoUsrLoggedIn = $logFilePath + "NoUsrLoggedIn-" + $cDate + ".log" 
$RemoteRegNotRunning = $logFilePath + "RemoteRegNotRunning-" + $cDate + ".log" 
$ErrorActionPreference = 'SilentlyContinue' 
Import-Module activedirectory 
Import-Module psremoteregistry 
$global:wmiErrors = @() 
$global:NoUserLoggedIn = @() 
$CompUserInfo = @() 
$arrCompLogonInfo = @() 
$arrRemoteRegSvcStopped = @() 
$arrNoMappedPrinters = @() 
$arrMappedPrinters = @() 
$statusMSG = "Getting Logged on User Information" 
$statusMSG2 = "Getting User SID from Active Directory" 
$statusMSG3 = "Collecting Mapped Printer Information" 
} 
PROCESS { 
$u = 1 
$Responded = VerifyConnectivity $compList 
if ($Responded.count -gt 0){ 
Talk $statusMSG 
foreach ($client in $Responded){ 
    [string]$c = $client.Computer 
    $numClient = $Responded.Count 
    $logonInfo = $null 
    Write-Progress -Activity $statusMSG -Status "Currently Processing: $c" -CurrentOperation "$u of $numClient" -PercentComplete ($u/$numClient*100)   
    $logonInfo = Get-WmiObject -ComputerName $c -Query "select * from win32_computersystem" | select Username 
    if ($?){ 
        if ($logonInfo.Username -ne $null){ 
            [string]$strUserName = $logonInfo.Username 
            $arrStrUserName = $strUserName.Split("\") 
            $strUser = $arrStrUserName[1]  
            $objCUinfo = New-Object psobject 
            $objCUinfo | Add-Member NoteProperty Workstation $c 
            $objCUinfo | Add-Member NoteProperty User $strUser 
            $CompUserInfo = $CompUserInfo + $objCUinfo             
        } 
        elseif ($logonInfo.Username -eq $null){ 
        $global:NoUserLoggedIn = $global:NoUserLoggedIn + $c 
        } 
    } 
    else { 
        $global:wmiErrors = $global:wmiErrors + "Could not Execute WMI Query to collect user logon information on $c" 
    } 
    $u = $u + 1 
    } 
    if ($CompUserInfo.Count -ge 1){ 
        $u = 1 
        Talk $statusMSG2 
        foreach ($logon in $CompUserInfo){ 
        [string]$userLN = $logon.User 
        $userCount = $CompUserInfo.count 
        [string]$wrksta = $logon.Workstation 
        Write-Progress -Activity $statusMSG2 -Status "Currently Processing: $userLN" -CurrentOperation "$u of $userCount" -PercentComplete ($u/$userCount*100) 
        $getSID = Get-ADUser -Identity $userLN | Select-Object SID 
        if ($?){ 
            [string]$sid = $getSID.sid 
            $LoggedOnUserInfo = New-Object psobject 
            $LoggedOnUserInfo | Add-Member Noteproperty Workstation $wrksta 
            $LoggedOnUserInfo | Add-Member Noteproperty User $userLN 
            $LoggedOnUserInfo | Add-Member Noteproperty SID $sid 
            $arrCompLogonInfo = $arrCompLogonInfo + $LoggedOnUserInfo 
        } 
        $u = $u + 1 
        } 
    } 
    if ($arrCompLogonInfo.count -ge 1){ 
        $u = 1 
        Talk $statusMSG3 
        foreach ($comp in $arrCompLogonInfo){ 
        $numT = $arrCompLogonInfo.Count 
        $Printers = $null 
        [string]$cn = $comp.Workstation 
        [string]$usid = $comp.sid 
        [string]$uName = $comp.User 
        Write-Progress -Activity $statusMSG3 -Status "Currently Processing: $cn" -CurrentOperation "$u of $numT" -PercentComplete ($u/$userCount*100) 
        $regStat = Get-Service -ComputerName $cn -Name "RemoteRegistry" 
        If ($?){ 
            If ($regStat.Status -eq "Running"){ 
                $Printers =  Get-RegKey -ComputerName $cn -Hive "Users" -Key "$usid\Printers\Connections" -Recurse 
                If ($Printers -ne $null){ 
                foreach ($printer in $Printers){ 
                [string]$printerKey = $printer.key 
                $arrPrinterKey = $printerKey.Split("\") 
                $PrinterNamePiece = $arrPrinterKey[3] 
                $arrPrinterParts = $PrinterNamePiece.Split(",") 
                $printServer = $arrPrinterParts[2] 
                $PrinterName = $arrPrinterParts[3] 
                $PrinterUnc = "\\$printServer\$PrinterName" 
                $printInfo = New-Object psobject 
                $printInfo | Add-Member NoteProperty Workstation $cn 
                $printInfo | Add-Member NoteProperty User $uName 
                $printInfo | Add-Member NoteProperty PrintServer $printServer 
                $printInfo | Add-Member NoteProperty PrinterName $PrinterName 
                $printInfo | Add-Member NoteProperty PrinterUNC $PrinterUnc 
                $arrMappedPrinters = $arrMappedPrinters + $printInfo 
                } 
                } 
                ElseIf ($Printers -eq $null){ 
                    $arrNoMappedPrinters = $arrNoMappedPrinters + "$uName has no mapped printers on $cn" 
                    } 
            } 
            ElseIf ($regStat.Status -eq "Stopped"){ 
                $arrRemoteRegSvcStopped = $arrRemoteRegSvcStopped + $cn 
            } 
        } 
        $u = $u + 1 
        } 
     
     
    } 
     
} 
} 
END { 
    $arrMappedPrinters | Export-Csv -Path $MappedPrinters 
    Add-Content $NoPrtMapLog $arrNoMappedPrinters 
    Add-Content $WmiErrorLog $wmiErrors 
    Add-Content $NoUsrLoggedIn $global:NoUserLoggedIn 
    Add-Content $RemoteRegNotRunning $arrRemoteRegSvcStopped 
    } 
} 
 
function Talk { 
param ( 
[parameter(ValueFromPipeline=$true)] 
$talk 
) 
Add-Type -AssemblyName System.Speech 
$synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer 
$synthesizer.Speak($talk) 
 
} 
 
cls 
$getPath = $(Read-Host "Enter path to the text file that contains the list of Computer Names`n") 
cls 
if ($getPath -like "*.txt"){ 
    $valid = Test-Path -Path $getPath 
    if ($valid -eq $true){ 
        $compList = get-content -Path $getPath  
        GetPrinterInfo $compList 
        Write-Host "The Script Output is located in $logfilepath" 
        Exit 
 
    } 
 
    Else { 
    Write-Host "Path to file is not valid" -ForegroundColor Red 
    } 
} 
Elseif ($getPath -notlike "*.txt"){ 
    Write-Host "Path to file is not valid" 
    Exit 
} 