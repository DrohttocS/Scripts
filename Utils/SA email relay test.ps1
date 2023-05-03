$domName = $RWC_DEAC.Name
$fName = $RWC_DEAC.FirstName
$expDate = $RWC_DEAC.Expires
$email = $RWC_DEAC.Email
$From = "docscan-svc@sourceamerica.org"
#############################    EMAIL    ####################################
# Uncomment for Live runs
#
$To = "shord@sourceamerica.org" #Test Address
# $To = $email

$Subject = "Test"
$Body = "This is only a test had this been a real email you would have been alerted."
$SMTPServer = "sourceamerica-org.mail.protection.outlook.com"
$SMTPPort = "25"
Send-MailMessage -From $From -to $To -Subject $Subject `
-Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `


##############################################################################