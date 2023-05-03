Remove-ADGroupMember -Identity la_WSRV5161_localadmin -Members SA_HernandeS12 Remove-ADGroupMember -Identity la_WSRV5161_localadmin -Members SA_HernandeS12 Remove-ADGroupMember -Identity la_WSRV5161_localadmin -Members SA_HernandeS12 $table = import-csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdmin_08152022.csv"
# Time to filter stuff 3076 2664 2302  


#2219
$table = $table | ?{$_."User from Group" -notlike "SA_*" -and $_."user" -notlike "*_*" -and $_."User from Group" -ne "ServerAdmin" -and $_."User from Group" -ne "SQLAdmin"}

# remove dupe users, "User from Group",User Consolidate Columns.
foreach ($row in $table | Where { $_.user -eq "Blank" }){$row.user = $row."User from Group"}
foreach ($row in $table | Where { $_."Has an SA User account" -eq "user" }){$row."Has an SA User account" = $row."Has an SA from Group"}
foreach ($row in $table | Where { $_."AD Obj Type" -eq "group" }){$row."AD Obj Type" = $row."User from Group"}
$table = $table | sort "User from Group",User -Unique  

# Save it off 
$table | Export-Csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\Users-Groups to update.csv"
$table |select Domain,domtype,server,user,"Has an SA User account","AD Obj Type","User from Group"| sort "AD Obj Type" | Out-GridView
$table |select Domain,domtype,server,user,"Has an SA User account","AD Obj Type","User from Group"| sort "AD Obj Type" | Export-Csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\Refined_List_08172022.csv" -NoTypeInformation

# Starting on Non SA 
    $nonSA = $table | ?{$_."Has an SA User account" -eq $false -and $_.DomType -eq 'corp'}
    $nonSA | Out-GridView

    $Counter = 0
    $NSA = Foreach ($line in $nonSA){
        $counter++
        Write-Progress -Activity 'Processing computers' -CurrentOperation $line -PercentComplete (($counter / $nonSA.count) * 100)

         $a = $line.domain
         $b = $line.domType
         $c = $line."User from Group"
         $d = $line.server
         $e = $line.user
         $f = $line."AD Obj Type"
         $g = $line."Has an SA User account"
         $h = Get-ADUser $e -Properties Department, Title, DisplayName,Manager,emailaddress
         $h = if([string]::IsNullOrWhiteSpace($h)){'NotFound'}Else{$h} 
         $i = $h.Department
         $j = $h.Title
         $k = $h.DisplayName
         $l = Get-ADComputer $d -Properties CanonicalName
         #$m = $l.DistinguishedName -replace '.+?,OU=(.+?),(?:OU|DC)=.+','$1'
         $m = $l.CanonicalName -replace ('WAWA.com/Servers/Apps/','') -replace($d,'') -replace “.$”
         $n = $h.Manager  -replace '(?:^|,)CN=([^,]+).*', '$1'
         $o = if([string]::IsNullOrWhiteSpace($h.emailaddress)){$h.UserPrincipalName}Else{$h.emailaddress} 
         $mgr = Get-ADUser $n -Properties emailaddress,DisplayName,Manager
         $n = $mgr.displayName
         $p = $mgr.emailaddress
 New-Object PSObject -Property ([ordered]@{
        Domain = $a
        DomType = $b
        UserGroup = $c
        Server = $d
        User = $e
        AccessGrantedFrom = $f
        SAAccount = $g
        DisplayName = $k
        Title = $j
        Dept = $i
        App = $m
        Owner = ''
        AccessRequired = ''
        Email = $o
        Manager = $n
        MgrEmail = $p
        })
    }
    $NSA | Out-GridView



        $path = "C:\Temp\"
        $file = 'NonSAUsers.csv'
        $path = $path+$file
        $NSA |Export-Csv -Path $path -NoTypeInformation





#SA accounts
$MissingSA = $table | ?{$_."Has an SA User account" -eq $true -and $_.DomType -eq 'corp'}
$counter = 0
$MSA = Foreach ($line in $MissingSA){
        $counter++
        Write-Progress -Activity 'Processing users' -CurrentOperation $line -PercentComplete (($counter / $MissingSA.count) * 100)

         $a = $line.domain
         $b = $line.domType
         $c = $line."User from Group"
         $d = $line.server
         $e = $line.user
         $f = $line."AD Obj Type"
         $g = $line."Has an SA User account"
         $h = Get-ADUser $e -Properties Department, Title
         $h = if([string]::IsNullOrWhiteSpace($h)){'NotFound'}Else{$h} 
         $i = $h.Department
         $j = $h.Title
 New-Object PSObject -Property ([ordered]@{
        Domain = $a
        DomType = $b
        UserGroup = $c
        Server = $d
        User = $e
        AccessGrantedFrom = $f
        SAAccount = $g
        Title = $j
        Dept = $i

 })
}

$MSA| Out-GridView
$file = 'User2Update.csv'
$path = $path+$file
$MSA |Export-Csv -Path $path -NoTypeInformation

$WSRMSA = $MSA | ?{$_.usergroup -like "LA_wsr*"}
$file = 'WsrvSAs.csv'
$path = $path+$file
$WSRMSA |Export-Csv -Path $path -NoTypeInformation
$WSRMSA.Count

$WSRMSA1 = $WSRMSA |select -First 1

foreach($SA in $WSRMSA){
$LAG = $SA.UserGroup
$user = "SA_" + $SA.User
Add-ADGroupMember -Identity $LAG -Members $user 
}
