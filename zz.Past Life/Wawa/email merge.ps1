

$NSA

$grouped = Group-Object mgremail
$grouped = $NSA | Group-Object mgremail -AsHashTable -AsString 


$res = foreach($mgr in $grouped.Values){
$b = $mgr.Manager
$b | select -Unique
$a = $mgr.mgremail 
$a | select -Unique
$c = ([char]9744)

$mgr| select DisplayName,User,Server, Title, app,AccessRequired |sort displayname| ft -AutoSize -Wrap | Out-String

}

$res | Out-HtmlView