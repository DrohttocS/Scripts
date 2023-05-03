    
    $Import = Import-Csv -Path C:\Support\Sam\NewRecon.csv
    $List = @()
     ForEach($user in $Import){
     $FNReconciler = $user.Reconciler
     $LNReconciler = $user.last
     $FNrev = $user.Reviewer
     $LNrev = $user.RevLast
               
     $List += [PSCustomObject]@{Reconlogin = Get-ADUser -Filter {(givenname -eq $FNReconciler  -and surname -eq $LNReconciler) } -Properties * | ? {$_.Description -notlike "*remote*"} | Select-Object samaccountname -ExpandProperty samaccountname
                                Reconciler =$user.Reconciler
                                Last       = $user.last
                                ReviewLogin = Get-ADUser -Filter {(givenname -eq $FNrev  -and surname -eq $LNrev) } -Properties * | ? {$_.Description -notlike "*remote*"} | select samaccountname -ExpandProperty samaccountname
                                Reviewer   =$user.Reviewer
                                RevLast     = $user.RevLast
                                Folders     = $user.Folders
                                Audit       =$user.Audit
                                }
            }

Foreach($items in $List){
$rootPath = '\\twb-files\Data\General\Internal Controls - DDA'
$Dir = $items.Folders
$SubF1 = $items.Reconciler ; $SubF1 = "Reconciler - $SubF1"
$SubF2 = $items.Reviewer   ; $SubF2 = "Reviewer - $SubF2"
$Reconcile = $items.Reconlogin
$Reviewer = $items.ReviewLogin
$Audit = $items.Audit
$Path4aclP  = "$Path\$dir"
$Path4acls1 = "$Path4aclP\$SubF1"
$Path4acls2 = "$Path4aclP\$SubF2"
write-host $Path4aclP  
write-host $Path4acls1 
write-host $Path4acls2 



#main
Write-Host "Starting on $Path4aclP"
New-Item -Path $rootPath -Name $dir -ItemType "directory" -Force
    $Acl = (Get-Item $Path4aclP).GetAccessControl('Access')
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4aclP -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reconcile,'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4aclP -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reviewer,'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4aclP -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit,'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4aclP -AclObject $Acl
    
#Sub1 Reconcile
Write-Host "Starting on $Path4acls1"
New-Item -Path $rootPath\$dir -Name $SubF1 -ItemType "directory" -Force
    $Acl = (Get-Item $Path4acls1).GetAccessControl('Access')
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reconcile, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4acls1 -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reviewer, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4acls1 -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4acls1 -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path4acls1 -AclObject $Acl


#sub2 Review

    Write-Host "Starting on $Path4acls2"
    New-Item -Path $rootPath\$dir -Name $SubF2 -ItemType "directory" -Force

        $Acl = (Get-Item $Path4acls2).GetAccessControl('Access')
        $acl.SetAccessRuleProtection($TRUE,$FALSE)
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reconcile, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
        $Acl.SetAccessRule($Ar)
        Set-Acl -path $Path4acls2 -AclObject $Acl
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reviewer, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
        $Acl.SetAccessRule($Ar)
        Set-Acl -path $Path4acls2 -AclObject $Acl
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
        $Acl.SetAccessRule($Ar)
        Set-Acl -path $Path4acls2 -AclObject $Acl
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
        $Acl.SetAccessRule($Ar)
        Set-Acl -path $Path4acls2 -AclObject $Acl


}
