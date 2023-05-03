    Get-ChildItem -Path \\dc2.rwc.com\is_apps -Recurse |`
foreach{
$Item = $_
$Type = $_.Extension
$Path = $_.FullName

$ParentS = ($_.Fullname).split("\")
$Parent = $ParentS[@($ParentS.Length - 2)]

$Folder = $_.PSIsContainer
$Age = $_.CreationTime

$Path | Select-Object `
    @{n="Name";e={$Item}},`
    @{n="Created";e={$Age}},`
    @{n="Folder Name";e={if($Parent){$Parent}else{$Parent}}},`
    @{n="filePath";e={$Path}},`
    @{n="Extension";e={if($Folder){"Folder"}else{$Type}}}`
}| Export-Csv C:\Test\is_apps.csv -NoTypeInformation 