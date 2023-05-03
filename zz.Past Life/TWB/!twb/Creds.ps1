cls
$username = "bvb\scottadmin"
$password = cat C:\Users\shord2126.BVB\Desktop\encPWD.txt | convertto-securestring
$cred   = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$Computer = "twb-dc1"


Get-WmiObject -Class Win32_BIOS  -Impersonation 3 -Credential $cred -ComputerName $Computer #| Select-Object -Property SerialNumber
