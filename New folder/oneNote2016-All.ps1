
[string]$extension = 'onetoc2'
[string]$executable = "C:\Program Files (x86)\Notepad++\notepad++.exe"

if (-not (Test-Path $executable))
{
	$errorMessage = "`'$executable`' does not exist, not able to create association"

	throw $errorMessage
}
$extension = $extension.trim()
if (-not ($extension.StartsWith(".")))
{
	$extension = ".$extension"
}
$fileType = Split-Path $executable -leaf
$fileType = $fileType.Replace(" ", "_")
$elevated = @"
    cmd /c "assoc $extension=$fileType"
    cmd /c 'ftype $fileType="$executable" "%1" "%*"'
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    Set-ItemProperty -Path "HKCR:\$fileType" -Name "(Default)" -Value "$fileType file" 
-ErrorAction Stop
"@
iex $elevated



set-Location HKCU:
Remove-ItemProperty -Path "Software\Microsoft\Office\16.0\OneNote\OpenNotebooks"  -Name "*"    

Set-Location c:
 Remove-Item -path $env:LOCALAPPDATA\Microsoft\OneNote\16.0 -Recurse -Force
 

New-PSDrive -Name "1note" -PSProvider FileSystem -Root \\twb-files\Notebooks
Set-Location 1note:
gci -Path $selection.FullName -Exclude "OneNote_RecycleBin" -Recurse -Directory |  Get-ChildItem -Filter *.onetoc2  | % { $_.FullName } | Invoke-Item 
Remove-PSDrive "1note" -Force
