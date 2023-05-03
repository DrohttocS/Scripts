do {

$L2A = Get-DfsrBacklog -SourceComputerName Twb-ham-files -DestinationComputerName Twb-kal-files
sleep 45
$L2ADiff = Get-DfsrBacklog -SourceComputerName Twb-ham-files -DestinationComputerName Twb-kal-files
$c1 = $L2A.count
$c2 = $L2Adiff.count
cls

Write-host "L2A = $c1"
Write-host "L2Adiff = $c2"

$var2 = $L2ADiff.FullPathName | sort
$var1 = $L2A.FullPathName | sort

#$var2 = $L2ADiff.FILENAME
#$var1 = $L2A.filename
Write-host "Files in the backlog"
$var2
Write-host "

files replicated 

"
(Compare-Object -ReferenceObject $var1 -DifferenceObject $var2 |
    ForEach-Object {
        $_.SideIndicator = $_.SideIndicator -replace '=>','Added to Replication' -replace '<=','Removed from Replication'
        $_
    }) | sort
Sleep 10

} UNTIL ($c1 -le 10)
