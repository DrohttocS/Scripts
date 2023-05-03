<# 

PullSecEvents.ps1

Author: Ryan Williams
Creation Date: 01/07/2021
Last Updated: 01/07/2021
Update History:
    01/07/2021 : v1.0 : RW : Initial release

Purpose:
This script will do the following:
    - Locate events in the Windows Event Log that match the filter 
    - Parse and extract specified values from each event and put them in an array
    - Output the array to a CSV file
    - Copy the CSV file to a network share
    - Send an email with a count of each event ID found
    - Remove temp files created from script

Currently it is mainly geared towards searching Security events, specifically 
event IDs 4771, 4740, and 4625. However, it should be easy to expand it to work 
with more event IDs. 

Usage:
This script can be ran ad-hoc or as a scheduled task.
Currently it is set up as a scheduled task, running at 12:01am every day.
To run on demand, either manually start the scheduled task or run this script
directly from a Powershell prompt. Default event IDs are 4771, 4740, and 4625 but
when running the script  you can specify your own event IDs with a parameter, in 
addition to the target server to run this on (default is "localhost" if not 
specified) and the name of the Event log to search (default is Security).

Example:
To search for a set of event IDs in the System event log on server "Server1":
    .\PullSecEvents.ps1 -IDList EventID1,EventID2,EventID3 -DC "Server1" -LogName "System"

#>
param(
    $LogName='Security',
    $DC='localhost',
    [Parameter(Position = 0)]
        [String[]]$IDList = @('4771','4740','4625')
)
function Format-Date() {
    $CSVDate = (Get-Date).toString("MM-dd-yyyy")
    return $CSVDate
}
$CSVDate = Format-Date
function New-CSVFile($_CSVDate) {
    $Path = "C:\Utilities\SecurityLogReview\$_CSVDate" + "_Sec_log_failures.csv"
    if (!(Test-Path -Path $Path)) {
            Add-Content -Path $Path -Value '"TimeWritten","MachineName","EventID","Message","User"'
            return $Path
        }
    else {
        return $Path
        }
}
$CSVOutput = New-CSVFile $CSVDate
function Find-SecEvents($_ID, $_LogName, $_StartDate, $_DC, $_CSVOutput, $_Counts) {
    $EventsRaw = Get-WinEvent -ComputerName $_DC -FilterHashTable @{ LogName = $_LogName; StartTime = $_startdate; ID = $_ID }
    $Events = @()
    $EventsRaw | ForEach-Object {
        $Events += [PSCustomObject]@{
            TimeWritten = $_.TimeCreated.toString("MM/dd/yyyy HH:mm:ss")
            MachineName = $_.MachineName
            EventID = $_.Id
            Message = ($_.Message).split(".")[0]
            User = ($_.Properties[0]).Value
        }
     $EventCount = $Events.count
     if ($_ID -eq '4771') {
        $Message1 = "(Kerberos pre-authentication failed.)"
        }
    elseif ($_ID -eq '4740') {
        $Message1 = "(A user account was locked out.)"
        }
    elseif ($_ID -eq '4625') {
        $Message1 = "(An account failed to log on.)"
        }
    }
    $Events | Export-Csv -Path $_CSVOutput -Append
    Write-Output "$EventCount : Event $_ID $Message1" | Out-File $Counts -Append
}
function Send-ReportEmail($_CSVDate, $_Counts) {
    $SMTPServer = "AMRNMCVPMG01.nmca.org"
    $Port = "25"
    [string]$Body = Get-Content -Path $_Counts -Raw
    $Subject = "Security Event Log Findings $CSVDate"
    $From = "SecurityEventLog@nidec-motor.com"
    $To = "Scott.Hord@nidec-motor.com" , "acimitiam@nidec-motor.com", "Janet.Lehmann@nidec-motor.com"
    Send-MailMessage -SmtpServer $SMTPServer -Port $Port -From $From -To $To -Subject $Subject -Body $Body
}
function Move-ReportCSV ($_CSVOutput) {
    $Destination = "\\stlsrv01\EMCG_IT\ISA\Saved_Security_Logs"
    $Source = $_CSVOutput
    Move-Item -Path $Source -Destination $Destination
}
$StartDate = Get-Date -date $(Get-Date).AddDays(-1)
$Counts = "C:\Utilities\SecurityLogReview\"+$CSVDate +"_EventIDCount.txt"
ForEach ($ID in $IDList) {
    Find-SecEvents $ID $LogName $StartDate $DC $CSVOutput
}
Send-ReportEmail $StartDate $Counts
Move-ReportCSV $CSVOutput
Remove-Item -Path $Counts -Force