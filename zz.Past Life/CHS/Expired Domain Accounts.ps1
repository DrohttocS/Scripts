#
# Shord 9/23/15
# Is currently configured to run from my local pc.
#
#  To deploy else where Creds need to be remapped or recreated.
#  No logging currently configured.
#
add-pssnapin quest.activeroles.admanagement
Import-Module ActiveDirectory
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
    $uscreds = Import-Credential -Path C:\admin\US_securestring.txt
    $mailcreds = Import-Credential -Path C:\admin\mail.txt
# Connect to US Domain Via ARS
    Connect-QADService -Service 'us.chs.net' -Credential $uscreds
# Get Password Expo age
    $MaxPassAge = (Get-QADObject (Get-QADRootDSE).defaultNamingContextDN).MaximumPasswordAge.days
# When to start sending msg's
    $DaysToExpire = 7
# Pull US Domain user info from OU 1501/Users and 1911/Users
    $VHMC = Get-QADUser -Enabled -PasswordNeverExpires:$false -SizeLimit 0 -SearchRoot US.chs.net/WA/Spokane1911/Users|`
           Select-Object Firstname,Lastname,Name,Email,@{Name="Expires";Expression={ $MaxPassAge - $_.PasswordAge.days }} |`
           Where-Object {$_.Expires -gt 0 -AND $_.Expires -le $DaysToExpire } 

    $DEAC = Get-QADUser -Enabled -PasswordNeverExpires:$false -SizeLimit 0 -SearchRoot US.chs.net/WA/Spokane1501/Users|`
           Select-Object Firstname,Lastname,Name,Email,@{Name="Expires";Expression={ $MaxPassAge - $_.PasswordAge.days }} |`
           Where-Object {$_.Expires -gt 0 -AND $_.Expires -le $DaysToExpire } 
# Split off Blank Email to check against RWC.COM
    $RWC = $DEAC| where {$_.email -eq $null}
# Merge RWC mail info 
    Set-location AD:
        foreach($rwc_user in $RWC){
                $rwcDisplay = ($rwc_user.FirstName) + " " + ($rwc_user.LastName) +"*"
                $rwcEmail = Get-ADUser -Filter { displayName -like $rwcDisplay } -Properties mail | Select-Object mail
                $rwc_user.email = $rwcEmail.mail
           }
# Remove Accounts missing Email Address
    $RWC_C = $RWC | where {$_.email -ne $null}
    $DEAC_C = $DEAC | where {$_.email -ne $null}
    $VHMC_C = $VHMC | where {$_.email -ne $null}
# Combine everything back together
    $VDR = $RWC_C + $DEAC_C + $VHMC_C
# Limit email to day 7 and 3 for sending notification. Then Kick out any Dupes
    $VDR = $VDR | where{$_.Expires -eq "7" -or $_.Expires -eq "3"}
    $VDR = $VDR | select -Unique email, Firstname, LastName, Expires
# Enable for list debugging
    #$VDR | Export-Csv "C:\admin\email_sent.csv" -Append -NoTypeInformation -Force 
# Logging Count and Date  
  $log ="Accounts Processed: " + $VDR.Count + " On " +(Get-Date -Format g)
  $log | Add-Content -Path "C:\admin\Expired Accounts.log"

#############################    EMAIL Loop   ################################
$From = "RWC_IS_Alert@rockwoodclinic.com"
 foreach($user2email in $VDR){
        $domName = $user2email.Name
        $fName = $user2email.FirstName
        $lName = $user2email.LastName
        $expDate = $user2email.Expires
        $email = $user2email.Email
        $To = $email
        $Subject = "(Action Required) CHS Password Expiration in $expDate days."
        $Body = "<body style='font-family:Arial, Helvetica, sans-serif; font-size:14px'><p>***This email is not a phishing email. This is being sent from your Local IT Department.***</p><p>If you are receiving this email, it has been identified that your CHS account (<b>EDD, Kronos, ALC, etc.</b>) password is set to expire in $expDate days. Please use the link below to reset your password to avoid a loss of access. Local IT will be issuing these advisories on a bi-weekly basis until we are migrated into the CHS domain for all network services.</p><p><a href='https://ilogin.chs.net/SSPRInt/private/Login'>https://ilogin.chs.net/SSPRInt/private/Login</a></p><p>If you have any difficulties, please call the Service Desk at 473-4357 or submit a ticket via MyIS on your Intranet page.</p><p>Thank you!</p>"
        $SMTPServer = "RWCHTS.RWC.com"
        $SMTPPort = "25"
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
-Credential ($mailcreds)
}
##############################################################################