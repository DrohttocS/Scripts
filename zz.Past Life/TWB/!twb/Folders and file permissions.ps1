$Folders = Get-Content -Path "C:\Support\Sam\folders.txt"
$dirpath = '\\twb-files\Data\General\Internal Controls - DDA'

cls
Foreach($dir in $Folders){
New-Item -Path $dirpath -Name $dir -ItemType "directory" -Force
New-Item -Path $dirpath\$dir -Name Reconcile -ItemType "directory" -Force
New-Item -Path $dirpath\$dir -Name Review -ItemType "directory" -Force
New-Item -Path $dirpath\$dir -Name Audit -ItemType "directory" -Force
}


$Rights= $null
$Rights = Import-Csv -Path C:\Support\Sam\Recon.csv


foreach($line in $Rights){

    # Main Folder

    $Base = '\\twb-files\Data\General\Internal Controls - DDA'
    $folder = $line.Folders
    $path = "$Base\$folder"
    $Acl = (Get-Item $path).GetAccessControl('Access')
    $Reconcile = $line.Reconcile
    $Reviewer = $line.Reviewer
    $Audit = $line.Audit
    
    
    Write-Host "Starting on $path  "
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reconcile,'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reviewer,'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit,'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl

    # Reconcile Folder
    $path = "$Base\$folder\Reconcile"
    $Acl = (Get-Item $path).GetAccessControl('Access')
    Write-Host "Starting on $path  "
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reconcile, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reviewer, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    
    
    
    # Audit Folder
    $path = "$Base\$folder\audit"
    $Acl = (Get-Item $path).GetAccessControl('Access')
    Write-Host "Starting on $path  "
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl


    # Review Folder
    $path = "$Base\$folder\Review"
    $Acl = (Get-Item $path).GetAccessControl('Access')
    Write-Host "Starting on $path  "
    $acl.SetAccessRuleProtection($TRUE,$FALSE)
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reconcile, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Reviewer, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Audit, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("bvb\TWB Domain Admins",'FULL','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $path -AclObject $Acl

    } 

      # Remove Access
     
  #   $r_acct = "Authenticated Users","Users","Administrators","MIKE ADMIN","firstcall","scott admin","Nick Super Admin","Kate Admin","Fcbetterway","MWService","Domain Admins","Enterprise Admins","Administrator","Patrick Admin","DomainAdmins"
     
   #  foreach($acct in $r_acct){
   #    $Ace = New-Object System.Security.AccessControl.FileSystemAccessRule ("$acct","FULL","ContainerInherit, ObjectInherit","None","Allow")
   #    $Acl.RemoveAccessRule($Ace)
   #    Set-Acl -path $Path2 -AclObject $Acl
   #    }
