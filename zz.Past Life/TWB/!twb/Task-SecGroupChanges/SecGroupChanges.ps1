
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
$mailcreds = Import-Credential -Path "C:\Support\Task-PwdEmail\mailcred.txt"





$DaysInactive = 1
$time = (Get-Date).Adddays(-($DaysInactive))
$now = (Get-Date -UFormat %D)
$yesterday = $time.ToString("yyyyMMdd")
$filetime = (Get-Date).ToString("yyyyMMdd")
$daily = (Get-Date).ToString("yyyy.MM.dd")
Get-ADGroup -Properties * -Filter { groupCategory -eq 'security' } |
ForEach-Object{
$hash=@{GroupName=$_.Name;Member='';Changed=$_.whenChanged}
$_ | Get-ADGroupMember -ea 0 -recurs |
ForEach-Object{
$hash.Member=$_.Name
New-Object psObject -Property $hash
}
}  |export-csv -NoTypeInformation -Path C:\Support\Task-SecGroupChanges\Data\$filetime`secgroups.csv


$var2 = import-csv -Path C:\Support\Task-SecGroupChanges\Data\$filetime`secgroups.csv
$var1 = import-csv -Path C:\Support\Task-SecGroupChanges\Data\$yesterday`secgroups.csv
(Compare-Object -ReferenceObject $var1 -DifferenceObject $var2 -Prop GroupName, Member |
    ForEach-Object {
        $_.SideIndicator = $_.SideIndicator -replace '=>','Added to group' -replace '<=','Removed from group'
        $_
    }) | sort Groupname,sideindicator,Member|
    Export-Csv -NoTypeInformation -Append -Path C:\Support\Task-SecGroupChanges\Data\$filetime`_Sec-Diff.txt
gc C:\Support\Task-SecGroupChanges\Data\$filetime`_Sec-Diff.txt |Select-Object -Unique > C:\Support\Task-SecGroupChanges\Data\$daily`_Sec-Diff.txt

$yest = (Get-date).Adddays(-($DaysInactive)).ToShortDateString()



$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: 0px auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

$TheList = Import-Csv C:\Support\Task-SecGroupChanges\Data\$daily`_Sec-Diff.txt |  ConvertTo-Html -Head $css -Body "<h1>Security Group Changes</h1>`n<h5>Generated on $(Get-Date)</h5>" | Out-String


#############################    EMAIL Loop   ################################
$email = "shord@trailwest.bank"
$From = "no-reply@trailwest.bank"
        $To = $email
        $subject = "Security Group Changes"


        



        $SMTPServer = "twb-exchange.bvb.local"
        $SMTPPort = "587"
        Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $TheList -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
        -Credential ($mailcreds)

##############################################################################
