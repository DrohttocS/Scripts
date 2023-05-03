Set-ExecutionPolicy Unrestricted
# Variables
$date = Get-Date
$date = $date.ToString('MM/dd/yyyy')
$tech  = $env:USERNAME
$entity = $env:USERDOMAIN
$enduser  = $null
$locationCode  = $null
$SerialNumber = $null
$Model = $null
$BiosFilter =$null
$hostname = $env:COMPUTERNAME
$dusername = "rwc\docdemo"
$dpassword = "W3lc0m31"
$cred   = new-object -typename System.Management.Automation.PSCredential -argumentlist $dusername, $dpassword

#$assetTag = $hostname.Substring(2)

# Data Collection

$colItems = get-wmiobject -class Win32_BIOS -namespace root\CIMV2
foreach ($objItem in $colItems) {
$SerialNumber = $objItem.SerialNumber
$BiosFilter = $objItem.SMBIOSBIOSVersion
}
$colItems = get-wmiobject -class Win32_computersystem -namespace root\CIMV2
foreach ($objItem in $colItems) {
$domain = $objItem.Domain
$Manufacturer = $objItem.manufacturer
$Model = $objItem.model
$Compname = $objItem.Name
}

$strFileName="C:\Program Files\Symantec\Symantec Endpoint Encryption Clients\TechLogs\GEFdeTcgOpal.log"
If (Test-Path $strFileName){
  $SeeDate = $SeeDate.LastWriteTime.ToString('MM/dd/yyyy')
}Else{
  $SeeDate ='Not Encrypted'
}

cls
echo "This program will ask you for the assigned user of this device, and, their location code.
Based off of that it will then rename and reboot the computer and output a inventory.txt file
"

$assetTag = Read-Host -Prompt "Asset Tag #: "
$trackingTag = Read-Host - Prompt "IT Tracking Tag #: "
$enduser = Read-Host -Prompt "Enduser this device is being deployed to: "
$locationCode = Read-Host -Prompt "Two digit Location Code: "
$d2join = Read-Host -Prompt "Domain to join: "
$NewName= $locationCode + $assetTag 

$output =@("$date,$tech,$d2join,$enduser,$locationCode,$SerialNumber,$Model,$BiosFilter,$NewName,$assetTag,$SeeDate,$trackingTag")
$output | Tee-Object -file \\dc2\IS_apps\DRIVER\z_automated\Inventory\$assetTag.txt -Append

# Rename, Join domain and reboot
#    (Get-WmiObject win32_computersystem).rename("$NewName")
#     add-computer -Credential $cred -DomainName $d2join
#     Restart-Computer

# $ComputerInfo = Get-WmiObject -Class Win32_ComputerSystem
# $ComputerInfo.Rename($NewName)