$NidecOU = "OU=AMR,OU=NIDEC,DC=nidecds,DC=com"

$amr=@()

$amrOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $NidecOU -SearchScope OneLevel -Properties CanonicalName | select name,DistinguishedName,CanonicalName 
foreach($ou in $amrOU){
$CanonicalName = $ou.CanonicalName
$selection = $ou.DistinguishedName
$name = $ou.name
$users=$null;$PCs=$null;$Servers=$null

$PCs = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -notlike '*Server*'}  -SearchBase $selection -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
$Servers = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -like '*Server*'}  -SearchBase $selection -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
$users = Get-ADUser -Filter * -SearchBase $selection -SearchScope Subtree 

$AMR += New-Object PSObject -Property ([ordered]@{
        "Name"           = $name
        "Canonical Name" = $CanonicalName
        "Workstations"   = $PCs.count
        "Servers"        = $Servers.count
        "User Accounts"  = $users.count
})
}

$amr


