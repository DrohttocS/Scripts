
import-module activedirectory

$DistributionGroup = "CN=Officers,OU=Distribution Groups,DC=bvb,DC=local"
$SecurityGroup = "CN=WFOfficers,OU=WebFilters,OU=Security Groups,DC=bvb,DC=local"

$AddMember = Get-ADGroupMember -Identity $DistributionGroup
         foreach ($User in $AddMember) {
                 Add-AdGroupMember -identity $SecurityGroup -Members $User.distinguishedName
                 }