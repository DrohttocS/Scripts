## Data Grab 
cls
$Edate = Get-Date -Format ".MM.dd.yyyy"
# Grab the newest files 
$csvPath = gci -Path $m_Srv -File |Sort-Object LastAccessTime -Descending |Select-Object -First 1
$csvData = Get-Content -Path $csvPath.PSPath | Select-Object -Skip 2 | ConvertFrom-Csv
$Header='System Transaction Value','Session Type','Transaction Type','Transaction Memo','Transaction Account Number','Session ID','Teller ID','Machine ID'

$RawData = $csvData|select $header |? (({$_.'Transaction Type' -like "Cash*" -or ($_.'Transaction Type' -like "Cash*" -and $_.'Transaction Type' -like "Check*") -and $_.'Session Type' -eq "PTM" -and $_.'System Transaction Value' -gt 1}))

## Formating
#$gdata = $RawData| Group-Object 'Transaction Account Number' -NoElement

$formData = $RawData| ForEach-Object -Process {
    [PSCustomObject]@{
     # TransCount = if($gdata.name -eq $_.'Transaction Account Number'){$gdata.name.GetLength($gdata.name -eq $_.'Transaction Account Number')}else {$gdata}
      Account = "{0:d10}" -f [int]$_.'Transaction Account Number'
      Teller = $_.'Teller ID'
      MachineID = switch ($_.'Machine ID') {
                           "HS1ITM3N84"  {"HS1 South"; break}
                           "HS1ITM4N84"   {"HS1 North"; break}
                           "ABBITM2N88" {"Airway"; break}
                           "LabITM"  {"Lolo"; break}
                            default {"Something else happened"; break}
                        }
      Type = $_.'Transaction Type'
      Amount = "{0:n2}" -f [int]$_.'System Transaction Value'
      SessionID = $_.'Session ID'
      # if ($_.'Transaction Memo'-le 1){"<Blank>"}
      Memo = if ($_.'Transaction Memo' -le 1){"<Blank>"}else{$_.'Transaction Memo'}
     # Total = "{0:c}" -f 0

  }
} 



$formData |sort ACCount| Export-Csv -Path C:\Support\$Edate'-ITM.csv' -NoTypeInformation


$gdata = $formData|group account # |sort account| Export-Csv -Path C:\Support\$Edate'-ITM.csv' -NoTypeInformation


$aggdata =  $GData | ForEach-Object -Process {
    [PSCustomObject]@{
    
     '# Transactions' = $_.'count'
      Account = $_.'name'
      Teller = ($_.'Teller') 
      MachineID = ($_.MachineID)
      Type = (@( $_.group.'Type') -join "`t")
      Amount = (@($_.group.'amount') -join "`t")
      Memo = (@($_.group.'memo') -join "`t")
     

    }
}

$aggdata | ft -Wrap -AutoSize


<#

$GData = $formData | Group-Object account
$aggdata =  $GData | ForEach-Object -Process {
    [PSCustomObject]@{
    
     '# Transactions' = $_.'count'
      Account = (@($_.group.'Account') -join "`r`n")
      Teller = (@($_.group.'Teller') -join "`r`n")
      MachineID = (@($_.group.MachineID) -join "`r`n")
      Type = (@( $_.group.'Type') -join "`r`n")
      Amount = (@($_.group.'amount') -join "`r`n")
      # if ($_.'Transaction Memo'-le 1){"<Blank>"}
      Memo = if ($_.Memo -le 1){"<Blank>"}else{$_.group.Memo}
     Total = "{0:c}" -f ($_.group.amount|Measure -sum).Sum

    }
}

$aggdata| Export-Csv -Path C:\Support\$Edate'-ITM.csv' -NoTypeInformation
start-process excel C:\Support\$Edate'-ITM.csv'


#>