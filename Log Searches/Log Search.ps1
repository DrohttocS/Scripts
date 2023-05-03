#$who =  'Do_Not_Reply.IndustrialAutomation@mail.nidec.com'
cls


$who = Read-Host "What are we looking for "
$header = "log-path","Line","Prot","Port","Port1","Time","IP","Action"

$data = Select-String  -Path 'C:\Program Files (x86)\hMailServer\Logs\*.log' -Pattern $who 

$data1 = $data


$data1 = $data1 -replace 'C:\\',''
$data1 = $data1 -replace "log:","log`t"
$data1 = $data1 -replace ':"','`t"'
$data1 = $data1 -replace '`t',"`t"


$dataset = $data1 | ConvertFrom-Csv -Delimiter "`t" -Header $header 
$dataset |select "Prot","Port","Port1","Time","IP","Action" -Last 100| ft -AutoSize -Wrap


#$dataset | export-csv -NoTypeInformation -Path C:\Temp\ora.txt 


