$uncServer = "D-EDPC020"
$uncFullPath = "$uncServer\my\backup\folder"
$username = "Administrator"
$password = "CHSADM1n"


New-PSDrive -Name $uncServer -PSProvider FileSystem -Root "\\$uncServer\c$\Documents and Settings" -Credential chsspokane\hords


 # Get-ChildItem "\\$uncServer\c$\Documents and Settings" | Sort-Object LastWriteTime -Descending | Select Name, LastWriteTime -first 1
