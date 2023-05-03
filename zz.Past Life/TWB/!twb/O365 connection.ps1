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

$mailcreds = Import-Credential -Path "C:\Support\AdminCredo365.txt"

#Open a session to O365
$ExOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $mailcreds -Authentication  Basic -AllowRedirection
import-PSSession $ExOSession -AllowClobber




$u = "mputn1940@trailwest.bank"


Get-CalendarDiagnosticLog -Identity $u -StartDate "1/1/2021 6:00:00 AM" 
Get-CalendarNotification -Identity $u
Get-CalendarProcessing -Identity $u | Format-List
Get-EventsFromEmailConfiguration -Identity $u
Get-MailboxCalendarFolder -Identity shord:\Calendar

Remove-CalendarEvents -Identity “MPutnam” -CancelOrganizedMeetings -QueryStartDate 1-1-2020 -QueryWindowInDays 90 -PreviewOnly -Verbose






Get-Mailbox $u

##  Email rules

$Usersemail ="shord2126@trailwest.bank"


Get-InboxRule -Mailbox $Usersemail | Select Name, Description,RuleIdentity,RunspaceId | fl


Disable-InboxRule -Identity "where my name is in the To box" -Mailbox lbrady@trailwest.bank


Remove-PSSession $Session

Restore-RecoverableItems -Identity shord  -FilterItemType IPM.note 


# Remove-InboxRule -Mailbox 84580631-c4d9-415d-8dd5-c78be65e433f -Identity "where my name is in the To box" 

#sign in
Connect-MsolService
Get-OwaMailboxPolicy | Format-Table Name,ReportJunkEmailEnabled

#   yR$q$1or2CjeY^ofJ



get-mailbox | restore-RecoverableItems -FilterStartTime "11/8/2019 12:00:00 AM" -FilterEndTime "11/9/2019 23:59:59" -FilterItemType IPM.Appointment -SourceFolder recoverableitems -ResultSize Unlimited -MaxParallelSize 10


Remove-PSSession $ExOSession


Restore-RecoverableItems -Identity RSeve4849,blange,alwbradley -FilterStartTime "11/8/2019 12:00:00 AM" -FilterEndTime "11/11/2019 23:59:59" -FilterItemType IPM.Note -SourceFolder recoverableitems -ResultSize Unlimited -MaxParallel 10



Restore-RecoverableItems -Identity Jroth,MHarris,tclairmont,VGarcia,bpetersen,cedwards,LLeiritz -FilterStartTime "11/8/2019 12:00:00 AM" -FilterEndTime "11/11/2019 23:59:59" -FilterItemType IPM.Note -SourceFolder recoverableitems -ResultSize Unlimited -MaxParal

Get-Mailbox |  Restore-RecoverableItems -FilterStartTime "11/8/2019 12:00:00 AM" -FilterEndTime "11/11/2019 23:59:59"   -ResultSize Unlimited 

Restore-RecoverableItems  -Identity Dcollins -ResultSize unlimited -SourceFolder RecoverableItems, PurgedItems    -FilterStartTime "11/8/2019 12:00:00 AM" -FilterEndTime "11/11/2019 23:59:59"

$myer = Get-RecoverableItems  -Identity mzins -FilterItemType IPM.Note   -ResultSize Unlimited 