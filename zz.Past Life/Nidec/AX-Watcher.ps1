
$LOG = 'System'
$Source = 'Service Control Manager'
$message = 'The Microsoft Dynamics AX Object Server 6.3$01-DAX2012_PROD service entered *'
$now = (Get-Date)
$hourago = (Get-Date).AddMinutes(-5)
$CurrentStatus = $null
$CurrentStatus = Get-EventLog -LogName $LOG -Source $Source -Message $message -After $hourago -Before $now -Newest 1
If($CurrentStatus -ne $null){
$StopTime = $CurrentStatus.TimeWritten
$ebody = $CurrentStatus | ConvertTo-Html -Property TimeGenerated,message   -Fragment
$CurrentStatus = $CurrentStatus | select -ExpandProperty ReplacementStrings
$service = $CurrentStatus[0]
$sstatus = $CurrentStatus[1]
$server = hostname


 #############################    EMAIL Loop   ################################
       $From = "no-replyd@nidec-motor.com"
       $To = "krushah@synoptek.com","jim.fitch@nidec-motor.com"
       # $To = "Scott.Hord@nidec-motor.com"  
        $Date = (Get-Date -UFormat "%A %m/%d/%Y %R %Z")
        $subject = "The AX Service has $sstatus on $server"
        $Body = "<body style='font-family:Arial, Helvetica, sans-serif; font-size:14px'><p>$ebody</p><p>Message sent at $Date</p></body>"
        $SMTPServer = "172.16.10.36"
        $SMTPPort = "587"
        Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
        
##############################################################################
}else{}
