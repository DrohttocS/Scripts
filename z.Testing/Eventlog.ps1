$sl = get-eventlog -logname security -instanceid 4624

$sl = get-eventlog -logname security -instanceid 4624 -newest 50
$logObjects = @(
    foreach($log in $sl)
    {
        $logArray = $log.message.split("`n")        

        [pscustomObject]@{
           # LogonType     = ($logArray|?{$_ -like "Logon Type:*"}).split(":")[1].trim() | if ($_ -lt 1){"unknown"}
            Workstation   = ($logArray|?{$_ -like "*Workstation Name:*"}).split(":")[1].trim()
            AccountName   = ($logArray|?{$_ -like "*Account Name:*"}).split(":")[1].trim()
            SourceAddress = ($logArray|?{$_ -like "*Source Network Address:*"}).split(":")[1].trim()
            ProcessName   = ($logArray|?{$_ -like "*Process Name:*"}).split(":")[1].trim()
        }

    }
)

if ($x -gt $y)
{
    
}