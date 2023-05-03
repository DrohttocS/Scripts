$Table = import-csv -Path "C:\Users\wcw101934\OneDrive - Wawa Inc\ServerAdminRights_Cleanup\Refined_List_08172022.csv"

$groups = $Table | ? {$_."AD Obj Type" -EQ 'Group'} | select server,"User from Group" | sort "User from Group" -Unique | sort server 

$counter = 0
$nested = foreach($line in $groups){
        Write-Progress -Activity 'Processing groups' -CurrentOperation $line -PercentComplete (($counter / $groups.count) * 100)

$ng = $null
$subNG = @()
$ng = Get-ADGroupMember $line."User from Group" |?{$_.objectClass -eq 'group'} | select name  -ExpandProperty name
        $subNG = Foreach($g in $ng){
            Get-ADGroupMember $g |?{$_.objectClass -eq 'group'} | select name  -ExpandProperty name 
        }
     
    New-Object PSObject -Property ([ordered]@{
            Server = $line.Server
            Group = $line."User from Group"
            NestedGroup  = $ng | Out-String 
            SubNests = $subNG| Out-String 


 }) 
}
$nested | ?{$_.nestedGroup -ne $null}  | sort server | ft -AutoSize -Wrap




Get-ADGroupMember $line."User from Group" |?{$_.objectClass -eq 'group'} | select name  -ExpandProperty name


$group = "ETL_HRIT"
$bpd = Get-ADGroupMember $group | select name 

Get-ADObject LEGALDPT