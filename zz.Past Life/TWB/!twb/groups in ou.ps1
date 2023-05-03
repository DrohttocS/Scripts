$ou= "OU=Security Committee - Key Logs,OU=Security Groups,DC=bvb,DC=local"
$Groups =  Get-ADGroup -Filter * -SearchBase $OU
$Data = foreach ($Group in $Groups) {
    Get-ADGroupMember -Identity $Group -Recursive | Select-Object @{Name='Group';Expression={$Group.Name}}, @{Name='Member';Expression={$_.Name}}
}