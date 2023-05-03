$Rawtable = Import-Csv -Path "C:\Users\wcw101934\Downloads\KathyNon_SA_.csv"
$NO_table = $rawtable | ?{$_.keep -eq 'No'}
$NO_DA = $NO_table | ?{$_.usergroup -eq ''}

$GA = $Rawtable | ?{$_.usergroup -notlike "LA_*"}
$a = $ga| sort name | Group-Object -Property UserGroup -AsHashTable -AsString

foreach($line in $a.Keys) {
$line
$a.$line | Export-Csv -Path c:\temp\ngw.csv -Append -NoTypeInformation
}
