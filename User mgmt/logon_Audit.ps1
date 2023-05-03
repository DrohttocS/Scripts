$Output = @()
$FilteredOutput = @()

        $LogFilter = @{
            LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
            ID = 21, 23, 24, 25
            StartTime = Get-Date -UFormat "%m/%d/%Y"
            }

        $AllEntries = Get-WinEvent -FilterHashtable $LogFilter -ComputerName (hostname)

        $AllEntries | Foreach { 
            $entry = [xml]$_.ToXml()
            [array]$Output += New-Object PSObject -Property @{
                TimeCreated = $_.TimeCreated
                User = $entry.Event.UserData.EventXML.User
                IPAddress = $entry.Event.UserData.EventXML.Address
                EventID = $entry.Event.System.EventID
                ServerName = (hostname)
                }        
            } 


    $FilteredOutput += $Output | Select TimeCreated, User, ServerName, IPAddress, @{Name='Action';Expression={
                if ($_.EventID -eq '21'){"IN Teller Admin"}
                if ($_.EventID -eq '22'){"Shell start"}
                if ($_.EventID -eq '23'){"Out Teller Admin"}
                if ($_.EventID -eq '24'){"Disconnected from Teller Admin"}
                if ($_.EventID -eq '25'){"Reconnected to Teller Admin"}
                }
            }

$First = $FilteredOutput  | Select-Object -First 1
$who = $First.User
$what = $First.Action
$where = $First.ServerName
$ip = $First.IPAddress22
$when = $First.TimeCreated
$First = $First | ConvertTo-Html -Fragment
$Subjline = "$who $what on $where from $ip at $when"
function Import-Credential 
{
   param
   (
     [Parameter(Mandatory=$true)]
     $Path
   )
    
  $CredentialCopy = Import-Clixml $path    
  $CredentialCopy.password = $CredentialCopy.Password | ConvertTo-SecureString    
  New-Object system.Management.Automation.PSCredential($CredentialCopy.username, $CredentialCopy.password)
}
# Creds 
$mailcreds = Import-Credential -Path "C:\Support\mailcred.txt"


#############################    EMAIL  ################################
       $From = "no-reply@trailwest.bank"
       $email = "shord@trailwest.bank"
        $To = $email
      
        $subject = $Subjline
        $Body = "<body style='font-family:Arial, Helvetica, sans-serif; font-size:14px'>$who</br>$what</br>$where</br>$ip</br>$when</body>"
        $SMTPServer = "twb-exchange16.bvb.local"
        $SMTPPort = "587"
    #exchange has a throttle set somewhere
     #   Start-Sleep -Seconds 15
    # Time to send it out         
        Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
        -Credential ($mailcreds)

##############################################################################



