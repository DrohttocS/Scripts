Backup-GPO -Name


$gpos = Get-GPO -All | Where-Object {$_.displayname -like "test - windows*"}
$gpos | select DisplayName | sort

 foreach($GP in $gpos){
 $GP = $GP.DisplayName
 
 $ou = $newADM.DistinguishedName.Split(',',4)[3]
 $GP   
 $tpath = $GP.Split("/")[0]

 $path = "C:\Utilities\" + $tpath + ".html"
 Get-GPOReport -Name $GP -ReportType 'HTML' -Path $path -Server STLUSNDSVPDC02

 "C:\Utilities"