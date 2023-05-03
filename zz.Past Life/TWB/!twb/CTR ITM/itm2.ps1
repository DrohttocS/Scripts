## Data Grab 
cls
$Edate = Get-Date -Format ".MM.dd.yyyy"
$csvData =@()
# Source
    $m_Srv ="\\twb-itm\Reports\Session-Detail\"
# Grab the newest files 
$csvPath = gci -Path $m_Srv -File |Sort-Object LastAccessTime -Descending |Select-Object -First 1
$csvData = Get-Content -Path $csvPath.PSPath | Select-Object -Skip 2 | ConvertFrom-Csv
$Header='System Transaction Value','Session Type','Transaction Type','Transaction Memo','Transaction Account Number','Session ID','Teller ID','Machine ID'

$csvData = $csvData|select $header |? (({$_.'Transaction Type' -like "Cash*" -or ($_.'Transaction Type' -like "Cash*" -and $_.'Transaction Type' -like "Check*") -and $_.'Session Type' -eq "PTM" -and $_.'System Transaction Value' -gt 1}))


$csvData | Group-Object $csvData.'Transaction Account Number'

$groupdata = $csvData | Group-Object 'Transaction Account Number'
$aggdata =  $groupdata | ForEach-Object -Process {
    [PSCustomObject]@{
      '# Transactions' = $_.'count'
      Account = "{0:D10}" -f [int]$_.name
      Type = (@($_.Group.'Transaction Type') -join "`r`n")
      'Cash In / out' =  "{0:c}" -f(@($_.Group.'System Transaction Value') -join "`r`n")
      
      Memo = if ($_.'Transaction Memo' -le 1){"<Blank>"}else{$_.'Transaction Memo'}

    }
}



$aggdata |Select-Object * | ft #Export-Csv  -Path C:\Support\$Edate-ITM.csv -NoTypeInformation



































## Formating
$csvData = $csvData| ForEach-Object -Process {
    [PSCustomObject]@{
      Account = "{0:d10}" -f [int]$_.'Transaction Account Number'
      Teller = $_.'Teller ID'
      Type = $_.'Transaction Type'
      Amount = "{0:n2}" -f [int]$_.'System Transaction Value'
      SessionID = $_.'Session ID'
      # if ($_.'Transaction Memo'-le 1){"<Blank>"}
      Memo = if ($_.'Transaction Memo' -le 1){"<Blank>"}else{$_.'Transaction Memo'}
      Total = ''
  }
} 
$csvData | sort account | ft -AutoSize 


## Binding calc
$Group = $csvData | Group-Object 'Transaction Account Number'
$Grouptot = $Group| ForEach-Object -Process {
    [PSCustomObject]@{
      #Account = $_.'name'
      Teller = (@($_.Group.'Teller ID') -join "`r`n")
      #Teller = (@($_.Group.'Teller ID') -join "`r`n")
      #Type = (@($_.Group.'Transaction Type') -join "`r`n")
      #Amount = (@($_.Group.'System Transaction Value') -join "`r`n")
      #SessionID = (@($_.Group.'Session ID') -join "`r`n")
      # if ($_.'Transaction Memo'-le 1){"<Blank>"}
      #Memo = if (@($_.Group.'Transaction Memo' -le 1)){"<Blank>"}else{(@($_.Group.'Transaction Memo') -join "`r`n")}
      #Total = '{0:n2}' -f ($_.Group.'System Transaction Value'|Measure -sum).Sum
  }
}

$Grouptot | ft -Wrap -AutoSize 


'Machine ID'

HS1ITM3N84 = HS1 South
HS1ITM4N84 = HS1 North
ABBITM2N88 = Airway
LabITM = Lolo




