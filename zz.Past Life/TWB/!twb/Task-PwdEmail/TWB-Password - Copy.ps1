Import-Module activedirectory
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
$maxPwdAge=(Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days
$DaysToExpire = 21
$BVBusers=`
Get-ADuser -Properties * -filter {(PassWordNeverExpires -eq "false") -and (Enabled -eq "True") -and (EmailAddress -ge 0)} |`
    Select-Object GivenName,surname,mail,PasswordLastSet,@{Name="Expires";Expression={($_.passwordlastset).AddDays($maxPwdAge)}},@{Name="Days";Expression={(($_.passwordlastset).AddDays($maxPwdAge) - (get-date)).days}} |`
    Where-Object {(($_.passwordlastset).AddDays($maxPwdAge) - (get-date)).days -ge 0  -and (($_.passwordlastset).AddDays($maxPwdAge) - (get-date)).days -le $daystoexpire  } 

# Limit email to day 7 and 3 for sending notification. Then Kick out any Dupes
    $BVBusers = $BVBusers | where{$_.days -eq "7" -or $_.days -le "3"}
    $BVBusers = $BVBusers | select -Unique mail, GivenName, Surname, days,expires
    

    
#############################    EMAIL Loop   ################################
$From = "no-reply@trailwest.bank"
 foreach($user2email in $BVBusers){
        $dow = $user2email.Expires.DateTime
        $fName = $user2email.GivenName
        $lName = $user2email.Surname
        $expDate = $user2email.days
       # $email = $user2email.Mail
       $email = "shord@trailwest.bank"
        $Bcc = "shord@trailwest.bank"
        $To = $email
        $doe =  $user2email.Expires.dayofweek
        $Weekends = 'Friday','Saturday','Sunday'
        
        if($Doe -in $Weekends -and $expDate -gt 3){
            $b = "Your Password will expire <strong>next weekend.</strong>"
         }elseif($Doe -in $Weekends -and $expDate -le 3){
            $b = "Your password will expire <strong>this weekend.</strong> Please reset it today!"
         }else{
            $b=""
        }

        $subject = "Your Windows Password will Expire $dow"
        $Body = "<body style='font-family:Arial, Helvetica, sans-serif; font-size:14px'><p>$FName,</p><p>You are receiving this email reminder because your Windows password is set to expire $dow.</p><p>Please reset your password <b>now</b> to avoid a loss of access. To reset your password press CTRL+ALT+Delete and choose &quot;Change Password&quot;.</p><p>If you have any difficulties, please call IT at EXT 4103.</p><p>Thank you!<br/><br/> <strong>Your</strong> TWB Support Team</p><p style='margin-top:50px;color:#F00;'>$b</p></body>"
        $SMTPServer = "twb-exchange.bvb.local"
        $SMTPPort = "587"
    #exchange has a throttle set somewhere
        Start-Sleep -Seconds 15
    # Time to send it out         
        Send-MailMessage -From $From -to $To -bcc $bcc -Subject $Subject `
        -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
        -Credential ($mailcreds)
}
##############################################################################


