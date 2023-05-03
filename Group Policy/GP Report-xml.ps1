$gpo1 = "Test - Windows Server 2016 - Member Server"
$gpo2 = "Test - Windows Appended 10/12r2/16/19"


Get-GPOReport -Name $gpo1 -ReportType Xml -Path "C:\temp\$gpo1.xml"
Get-GPOReport -Name $gpo2 -ReportType Xml -Path "C:\temp\Test - Windows Appended.xml"
