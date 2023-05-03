$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

# servers to monitor
$servers = "AMRNDSVPAX11","AMRNDSVPAX12","AMRNDSVPAX13"
"The Microsoft Dynamics AX Object Server 6.3$01-DAX2012_PROD"

$sess = New-PSSession -ComputerName $servers -Credential $AdminCred

$CurrentStatus = Invoke-Command -Session $sess -ScriptBlock{cls

Ipconfig
}



$Status = $CurrentStatus.Status

$CurrentStatus

 #Get current status
 if ($Status -eq 'Running')
 {
 Write-Host 'Running'
 }
 else
 {
 Write-Host 'Not Running'
 }


 #############################    EMAIL Loop   ################################
       $From = "Scott.Hord@nidec-motor.com"
       #$email = "krushah@synoptek.com"
        $To = "Scott.Hord@nidec-motor.com"  
                $Date = (Get-Date -UFormat %c)
        $subject = "Service $service has stop at $Date"
        $Body = "<body style='font-family:Arial, Helvetica, sans-serif; font-size:14px'><p>$CurrentStatus</p></body>"
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

