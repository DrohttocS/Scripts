$Mailusername = "scohor"
$Mailpassword = Get-Content 'C:\admin\RWC_CHS_SecureString.txt' | ConvertTo-SecureString
$Mailcred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $Mailusername, $Mailpassword


$domName = $RWC_DEAC.Name
$fName = $RWC_DEAC.FirstName
$expDate = $RWC_DEAC.Expires
$email = $RWC_DEAC.Email
$From = "RWC_IS_Alert@rockwoodclinic.com"
#############################    EMAIL    ####################################
# Uncomment for Live runs
#
$To = "hords@empirehealth.org" #Test Address
# $To = $email

$Subject = "Password for us\$domName will expire in $expDate days."
$Body = "Dear $FName,<br/> Your US domain password will expire in $expDate days. <br/> Please go to <a href='https://ilogin.chs.net/'>https://ilogin.chs.net</a> and reset your password.<br/> This will affect all CHS hosted applications; Email, Kronos, ALC, EDD etc. <br/><br/>If you have questions please call 473-HELP (4357)"
$SMTPServer = "RWCHTS.RWC.com"
$SMTPPort = "25"
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
-Credential ($Mailcred)

##############################################################################