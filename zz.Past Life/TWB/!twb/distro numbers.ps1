$report = @()
#Get distribution groups
$distgroups = @(Get-DistributionGroup -ResultSize Unlimited)

#Process each distribution group
foreach ($dg in $distgroups)
{
    $count = @(Get-ADGroupMember -Recursive $dg.DistinguishedName).Count

    $reportObj = New-Object PSObject
    $reportObj | Add-Member NoteProperty -Name "Group Name" -Value $dg.Name
    $reportObj | Add-Member NoteProperty -Name "DN" -Value $dg.distinguishedName
    $reportObj | Add-Member NoteProperty -Name "Manager" -Value $dg.managedby.Name
    $reportObj | Add-Member NoteProperty -Name "Member Count" -Value $count

    Write-Host "$($dg.Name) has $($count) members"

    $report += $reportObj

}
$report | Export-CSV -Path \\twb-files\Data\General\OPERATIONS\App_Install\S.xtras\DistributionGroupMemberCounts.csv -NoTypeInformation -Encoding UTF8