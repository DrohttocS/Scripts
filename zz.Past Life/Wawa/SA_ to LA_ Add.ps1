$table = Import-Csv -Path "C:\Users\wcw101934\OneDrive - Wawa Inc\ServerAdminRights_Cleanup\SA User updated withinScope.csv"
$a = $table| sort name | Group-Object -Property user -AsHashTable -AsString



 foreach($line in $a.Keys) {
try{
    $name =  $line
    $line =  $a.$name | select Usergroup,server,user,AccessGrantedFrom,title,dept
    #remove la groups they are already in
    $NLAG = $line | ?{$_.usergroup -notlike "LA_*"}
    $SA_ = 'SA_' + $name

        #Add the user to the group
 foreach($Add in $NLAG){
    $LaG = 'LA_' + $Add.server + '_LocalAdmin'         
Write-Host "Adding $SA_ to $LaG "
    Add-ADGroupMember -Identity $LaG -Members $SA_ -WhatIf
 }
     
}
Catch{Write-Warning "Could NOT find LA_ Group: $LaG"}   
}



