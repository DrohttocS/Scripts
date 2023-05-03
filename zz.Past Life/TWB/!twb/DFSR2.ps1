$llo = "twb-files"
$ABB = "twb-abb-files"
$ham = "twb-ham-files"
$Kal = "twb-kal-files"

$h2L = Get-DfsrBacklog -SourceComputerName $ham -DestinationComputerName $llo
$h2a = Get-DfsrBacklog -SourceComputerName $ham -DestinationComputerName $abb
$h2K = Get-DfsrBacklog -SourceComputerName $ham -DestinationComputerName $Kal
$h2L = $h2L.count
$h2a = $h2H.count
$h2K = $h2K.count
$L2H = Get-DfsrBacklog -SourceComputerName $llo -DestinationComputerName $ham
$L2A = Get-DfsrBacklog -SourceComputerName $llo -DestinationComputerName $abb
$l2K = Get-DfsrBacklog -SourceComputerName $llo -DestinationComputerName $Kal
$l2h = $L2h.count
$l2a = $L2A.count
$L2K = $L2K.count
$A2L = Get-DfsrBacklog -SourceComputerName $abb -DestinationComputerName $llo
$A2H = Get-DfsrBacklog -SourceComputerName $abb -DestinationComputerName $ham
$A2K = Get-DfsrBacklog -SourceComputerName $abb -DestinationComputerName $Kal
$A2L = $A2L.count
$A2H = $A2H.count
$A2K = $A2K.count
$K2L = Get-DfsrBacklog -SourceComputerName $kal -DestinationComputerName $llo
$K2H = Get-DfsrBacklog -SourceComputerName $kal -DestinationComputerName $ham
$K2A = Get-DfsrBacklog -SourceComputerName $kal -DestinationComputerName $abb
$K2L = $K2L.count
$K2H = $K2H.count
$K2A = $K2A.count
cls

Write-Host "$ham to $llo = $h2L"
Write-Host "$ham to $abb = $h2a"
Write-Host "$ham to $kal = $h2k"

Write-Host "$llo to $ham = $l2h"
Write-Host "$llo to $abb = $l2a"
Write-Host "$llo to $kal = $l2k"

Write-Host "$abb to $llo = $a2L"
Write-Host "$abb to $ham = $a2h"
Write-Host "$abb to $kal = $a2k"

Write-Host "$kal to $llo = $k2L"
Write-Host "$kal to $ham = $k2h"
Write-Host "$kal to $abb = $k2a"

