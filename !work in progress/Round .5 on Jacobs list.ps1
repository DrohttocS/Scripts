$AZureList = Import-Csv -Path C:\pstemp\Licensed_Hourly_Users_2023-5-10.csv
$Securitylist = $res | ?{$_."MB Flag" -ne "Y" -and $_."Salary Or Hourly Code" -eq "H" -and $_.enabled }

# Import the CSV files
$csv2 = Import-Csv -Path C:\pstemp\Licensed_Hourly_Users_2023-5-10.csv
$csv1 = Import-Csv -Path C:\pstemp\HourlyExceptions.csv

# Merge the CSV files based on the common column "ID"
$mergedCsv = $csv1 | Join-Object -Right $csv2 -RightProperties "ID" -LeftJoinProperty "ID"

# Add a header if the columns match
if (($csv1[0].PSObject.Properties.Name -join ",") -eq ($csv2[0].PSObject.Properties.Name -join ",")) {
    $header = "ID," + ($csv1[0].PSObject.Properties.Name -notmatch "ID" -join ",")
    $mergedCsv = $mergedCsv | Select-Object -Property $header
}

$joined = Join-Object -Left $csv1 -Right $csv2 -LeftJoinProperty L_ID -RightJoinProperty R_ID -Type AllInBoth