# get Local Admin account and add SA account

$AD_LA_Accounts = Get-ADGroup -Filter {Name -like "*_Localadmin"}
$AD_LA_Accounts.Count


    $Contacts = Foreach($group in $AD_LA_Accounts){
        Write-Progress -Id 0 "Groups $group"
       $GrpMems = Get-ADGroupMember $group | ?{$_.name -notlike "*_*"}   
        
        Foreach($gm in  $GrpMems ){
         Write-Progress -Id 1 -ParentId 0 "Users $gm" 
            $SAA =  ("SA_" + $Gm.name) 
         New-Object PSObject -Property ([ordered]@{
            User = $Gm.name 
            Group = $group.Name
            'SA Account' = [bool] (Get-ADUser -Filter { SamAccountName -eq $SAA } )
            })
    }

}

$SA_Contacts = $Contacts | Group-Object -Property User | 
    Select-Object @{Name = "Count";    Expression = {$_.Group.count}},
                  @{Name = "User";     Expression = {($_.Group.User | Select-Object -Unique)}},
                  @{Name = "SA Account";     Expression = {($_.Group."SA Account" | Select-Object -Unique)}},
                  @{Name = 'Group(s)'; Expression = {($_.Group.group | Select-Object -Unique) -join ","}} | sort User



$SA_Contacts

 #$SA_Contacts | Export-Csv -Path C:\Temp\LA_Groups_with_NON_SA_Admin.csv -NoTypeInformation
