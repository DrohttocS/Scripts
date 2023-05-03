
$HomeFolders = Get-ChildItem 'D:\Users' -Directory 
#$HomeFolders = $HomeFolders[0..9]

foreach ($HomeFolder in $HomeFolders) {
    $Path2 = $HomeFolder.FullName
    $Acl = (Get-Item $Path2).GetAccessControl('Access')
    $Username = $HomeFolder.Name
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    
    Write-Host "Starting on $path2  "
   

    
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path2 -AclObject $Acl

      
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("twb domain admins", 'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path2 -AclObject $Acl

      
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM", 'FULL','ContainerInherit,ObjectInherit', 'None', 'ALLOW')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path2 -AclObject $Acl  
   
  # Remove Access
     
  #   $r_acct = "Authenticated Users","Users","Administrators","MIKE ADMIN","firstcall","scott admin","Nick Super Admin","Kate Admin","Fcbetterway","MWService","Domain Admins","Enterprise Admins","Administrator","Patrick Admin","DomainAdmins"
     
   #  foreach($acct in $r_acct){
   #    $Ace = New-Object System.Security.AccessControl.FileSystemAccessRule ("$acct","FULL","ContainerInherit, ObjectInherit","None","Allow")
   #    $Acl.RemoveAccessRule($Ace)
   #    Set-Acl -path $Path2 -AclObject $Acl
   #    }


    Get-Acl $Path2 | Ft -AutoSize -Wrap
    #Get-Acl $Path2 | Ft -AutoSize -Wrap >> C:\Users\scottadmin\Desktop\Home_ACL.txt 
    
 }