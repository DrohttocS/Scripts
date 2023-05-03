Import-Module ActiveDirectory
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$CloneAC = Read-Host "Account to clone from: "
$user2copy = Get-ADUser -identity $CloneAC
$pcname = Read-Host "Account to clone to: "
$CopyFromUser = Get-ADUser $user2copy -prop MemberOf
$CopyToUser = Get-ADUser $pcname -prop MemberOf
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser -Credential $AdminCred
 

$NameADM = Read-Host 'Enter name to search for'
$NameADM = "*$NameADM*"
$ADM2create = Get-ADUser -filter { DisplayName -like $NameADM } | sort Name
$menu = @{};cls
for ($i=1;$i -le $ADM2create.count; $i++) {
    Write-Host "$i. $($ADM2create[$i-1].Name)" -ForegroundColor Green
    $menu.Add($i,($ADM2create[$i-1].SamAccountName))
    }
[int]$ans = Read-Host 'Select User to Promote'
$selection = $menu.Item($ans) 
$ADM2create = Get-ADUser -Identity $selection -Properties *

 $ADM = New-Object PSObject -Property ([ordered]@{
            Identity          = $ENV:COMPUTERNAME
            "Netlogon Service"   = get-service -Name "Netlogon" -ErrorAction SilentlyContinue | select -ExpandProperty status
            "AD Services"       = get-service -Name "NTDS" -ErrorAction SilentlyContinue | select -ExpandProperty status
            "DNS Service Status"  = get-service -Name "DNS" -ErrorAction SilentlyContinue | select -ExpandProperty status
            "Netlogon Test"     = $netlogonT
            "Replication Test"   = $ReplicationT
            "Services Test"      = $ServicesT
            "Advertising Test"   = $AdvertisingT 
            "Intersite Test"     = $IntersiteT 
            "KCC Test"           = $KccEventT 
            "Topology Test"      = $TopologyT
            "SystemLog Test"     = $SystemLogT
            "FSMO Test"          = $KnowsOfRoleHoldersT



$SearchName = Read-Host 'Enter sam acct name to copy permissions from'
$SearchName = "*$SearchName*"
$user2copy = Get-ADUser -filter { samaccountname -like $SearchName }
$Dn = $user2copy.DistinguishedName
$U2CLEN = ($user2copy.Name.Length) + 5
$T2tRUN =   $Dn.Length - $U2CLEN
$ou = $Dn.Substring($Dn.Length-$T2tRUN)
