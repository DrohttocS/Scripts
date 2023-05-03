$Edate = Get-Date -Format ".MM.dd.yyyy"

# Source
    $m_Srv ="\\twb-itm\Reports\Session-Detail\"
# Grab the newest files 
    $csvPath = gci -Path $m_Srv -File |Sort-Object LastAccessTime -Descending |Select-Object -First 1
$csvData = Get-Content -Path $csvPath.PSPath | Select-Object -Skip 2 | ConvertFrom-Csv
$Header='System Transaction Value','Session Type','Transaction Type','Transaction Memo','Transaction Account Number'
$csvData = $csvData|select $header |? {$_.'Transaction Type' -like "Cash*" -and $_.'Session Type' -eq "PTM" -and $_.'System Transaction Value' -gt 1}


$groupdata = $csvData | Group-Object 'Transaction Account Number'
$aggdata =  $groupdata | ForEach-Object -Process {
    [PSCustomObject]@{
      '# Transactions' = $_.'count'
      Account = "{0:D10}" -f [int]$_.name
      'Cash In / out' =  $_.Group.'System Transaction Value'
      Total = "{0:c}" -f ($_.Group.'System Transaction Value'|Measure -sum).Sum
      Memo = if (!$_.'Transaction Memo'-le 1){"<Blank>"}

    }
}



$aggdata | ft -AutoSize 


Get-EC2Instance | Select -Expand RunningInstance | Select @{Name="InstanceType";Expression={$_.InstanceType.Value}},"InstanceID"
