$DaysInactive = 1
$time = (Get-Date).Adddays(-($DaysInactive))
$now = (Get-Date -UFormat %D)
$yesterday = $time.ToString("yyyyMMdd")
$filetime = (Get-Date).ToString("yyyyMMdd")
$daily = (Get-Date).ToString("yyyy.MM.dd")
New-Item "C:\Support\Task-SecGroupChanges\Data\$filetime" -ItemType directory

# daily check for changed groups

    $groups = Get-ADGroup -filter "Groupcategory -eq 'Security'  -AND Member -like '*'" |
    foreach {
    Write-Host "Exporting $($_.name)" -ForegroundColor Cyan
    $name = $_.name -replace " ","-"
    $file = Join-Path -path "C:\Support\Task-SecGroupChanges\Data\$filetime" -ChildPath "$name.csv"
    Get-ADGroupMember -Identity $_.distinguishedname -Recursive |
    Get-ADObject -Properties SamAccountname,Title,Department |
    Select Name,SamAccountName,Title,Department,DistinguishedName,ObjectClass |Export-Csv -Path $file -NoTypeInformation
}

#compare
    $today_path = "C:\Support\Task-SecGroupChanges\Data\$filetime"
    $Yesterday_path = "C:\Support\Task-SecGroupChanges\Data\$yesterday"

$TodayF = @{}
$TodayF = @{}

$TodayF = Get-ChildItem $today_path
$YesterdayF = Get-ChildItem $Yesterday_path
if ($myval -eq $null) { "new value" } else { $myval }

$diffs = Compare-Object -ReferenceObject $YesterdayF  -DifferenceObject $TodayF -Property Name,Length -PassThru |
ForEach-Object {
    [PSCustomObject]@{
      Name  = $_.Name
      Yes_Path = ($YesterdayF | Where-Object Name -eq $_.Name).FullName
      Tod_Path = ($TodayF | Where-Object Name -eq $_.Name).FullName
      Yes_file = ($YesterdayF | Where-Object Name -eq $_.Name).BaseName
      Tod_file = ($TodayF | Where-Object Name -eq $_.Name).BaseName
    }
  }
  
$diffs = $diffs |sort  name -Unique 

foreach($diff in $diffs){

$Yes_chan = gc $diff.Yes_Path
$tod_Base = import-csv -Path "$diff.Tod_Path"


(Compare-Object -ReferenceObject $Yes_chan -DifferenceObject $tod_Base -Prop SamAccountName |
    ForEach-Object {
    $groupName = $diff.name
        $_.SideIndicator = $_.SideIndicator -replace '=>',"Added to group $groupName" -replace '<=',"Removed from group $groupName"
        $_ 
    })
    }
