    $List = @()
    $Reconlogin =@()
    $Reconcilers=@()
    $List = Import-Csv -Path C:\Support\Sam\NewRecon.csv

    ForEach($user in $list.Reconlogin){    
    $dn = "$user*"
    $Reconlogin += Get-ADUser -Filter { samAccountName -like $dn  -and samAccountName -notlike "*remote"} | Select samAccountName 
    }
    ForEach($user in $list.ReviewLogin){    
    $dn = "$user*"
    $ReviewLogin += Get-ADUser -Filter { samAccountName -like $dn  -and samAccountName -notlike "*remote"} | Select samAccountName | fl
    }




        $FileList = get-childitem | Select-Object Name, DirectoryName

foreach ($item in $FileList)
{    
    $FileListOBJ += [PSCustomObject]@{ServerName="ServerName";FileName=$item.Name;Directory=$item.DirectoryName}
}
Reconlogin  : 
Reconciler  : Samantha
Last        : Heil
ReviewLogin : 
Reviewer    : Haley
RevLast     : Bradley
Folders     : 1002320 - BHC - Haley Bradley 
Audit     