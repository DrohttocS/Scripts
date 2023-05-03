#ADD-ADGroupMember “RDPEnabled” –members “STATION01$”
# $pcs ="d-is14585"
 $pcs = Get-Content -Path "C:\admin\Passport computers.txt"
Foreach ($pc in $pcs){
$pc2add = $pc + "$"
ADD-ADGroupMember “Passport ScheduleSmart” –members $pc2add
}
