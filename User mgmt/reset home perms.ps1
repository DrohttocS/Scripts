$cred=Get-Credential
$sess = New-PSSession -Credential $cred -ComputerName wa1501whome01
Enter-PSSession $sess

$HomeFolders = Get-ChildItem '\\wa1501wHome01\d$\ehshome\' -Directory
foreach ($HomeFolder in $HomeFolders) {
    $Path = $HomeFolder.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $HomeFolder.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}


Exit-PSSession
Remove-PSSession $sess




