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


#############################    EMAIL Loop   ################################
       $From = "no-reply@trailwest.bank"
       $email = "shord@trailwest.bank"
        $To = $email
        $Date = (Get-Date -UFormat %c)
        $subject = "$env:Username in $env:ComputerName $Date"
        $Body = "<body style='font-family:Arial, Helvetica, sans-serif; font-size:14px'><p>$env:Username in $env:ComputerName $Date</p></body>"
        $SMTPServer = "twb-exchange16.bvb.local"
        $SMTPPort = "587"
    #exchange has a throttle set somewhere
        Start-Sleep -Seconds 15
    # Time to send it out         
        Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
        -Credential ($mailcreds)

##############################################################################



