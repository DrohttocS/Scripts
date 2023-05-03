$table = Import-Csv -Path "C:\Users\wcw101934\OneDrive - Wawa Inc\ServerAdminRights_Cleanup\SA User updated withinScope.csv"
$table = $table | ?{$_.server -like "wsrv*"}
$a = $table| sort name | Group-Object -Property user -AsHashTable -AsString
Function Get-Uinfo{
 Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $Name
    )

 $U = Get-ADUser $Name -Properties UserPrincipalName,emailaddress,manager
    $email = if([string]::IsNullOrWhiteSpace($u.emailaddress)){$u.UserPrincipalName}Else{$u.emailaddress} 
    $mgr = Get-ADUser $u.manager -Properties emailaddress,DisplayName,Manager
    $n = $mgr.displayName
    $p = $mgr.emailaddress
    $SamAcct = $u.SamAccountName
    $SA = "SA_"+ $u.SamAccountName
    $SA = Get-ADUser $sa | select -ExpandProperty SamAccountName




New-Object PSObject -Property ([ordered]@{
    FName = $u.GivenName
    LName = $u.Surname
    Email = $email
    Sam = $SamAcct
    SAcct = if([string]::IsNullOrWhiteSpace($sa)){'Missing SA acct.'}Else{$SA} 
    SrvC = $srvC
    SrvL = $srvL

        })
}

 foreach($line in $a.Keys) {
 try{   
    $name =  $line
    $line =  $a.$name | select Usergroup,server,user,AccessGrantedFrom,title,dept
    $srv = $line | select -ExpandProperty server 
    $srvC = If($srv.Count -eq 1){$srv}else{$srv -join ', '}
    $srvL = If($srv.Count -eq 1){$srv}else{$srv -join "`n"}
    Get-Uinfo $name | Export-Csv -Path C:\Temp\saMail2.csv -NoTypeInformation -Append
    }Catch{
    Write-Warning "$name can't be found"
}
}





Function Z_Access-Check{
   Process{
        

   Try{if($_ -like "SA_*"){$true}else{[bool]("SA_" + $_ | Get-ADUser -ErrorAction SilentlyContinue)}}catch{Write-Output $_.exception.message}
           }

}
$name = 'abbatej'