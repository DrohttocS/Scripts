$keys = get-content 'C:\Documents and Settings\scohor\desktop\bad_shares.txt'
$path = "HKLM:SYSTEM\CurrentControlSet\Services\lanmanserver\Shares"
foreach ($key in $keys){
Remove-ItemProperty -Path $path -Name $key 
