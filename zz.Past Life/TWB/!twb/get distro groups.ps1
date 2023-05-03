$report = @()
#Get distribution groups
$distgroups = @(Get-DistributionGroup -ResultSize Unlimited)

foreach ($dg in $distgroups)
{
    $count = @(Get-ADGroupMember -Identity $dg.Name).name.count
    $members = @(Get-ADGroupMember -Identity $dg.Name).name

   $reportObj = New-Object PSObject
   $reportObj | Add-Member NoteProperty -Name "Group Name" -Value $dg.Name
   $reportObj | Add-Member NoteProperty -Name "Member Count" -Value $count
   $reportObj | Add-Member NoteProperty -Name "Members" -Value (@($members) -join ',')
   
   $reportObj | Export-Csv -Path C:\Support\DistroGroups2.csv -Append -NoTypeInformation
  

    $report += $reportObj    }
     $report 




     foreach($dg in $distgroups){

