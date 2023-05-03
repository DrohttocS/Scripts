#Powershell script to set home folder permissions for all folders in the specified path

#get all folders in path set below and place in variable, enter the path to the home folder below
$HomeFolders=GET-CHILDITEM "C:\Users\scohor\Desktop\fake H"
 
#Loop to modify each folder in the path set above
Foreach ($Folder in $HomeFolders)
{
#set domain below
$Username=’rwc\’+$Folder.Name
 
#retrieve current folder ACL's
 $Access=GET-ACL $Folder
 

#Set Rights that will be changed in following variables
#for rights available see http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights.aspx
$FileSystemRights=[System.Security.AccessControl.FileSystemRights]"FullControl"
$AccessControlType=[System.Security.AccessControl.AccessControlType]"Allow"
$InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$PropagationFlags=[System.Security.AccessControl.PropagationFlags]"InheritOnly"
$IdentityReference=$Username

#print what folder is being modified currently
Write-host $Username

#Build command to modify folder ACL's and place in variable
$FileSystemAccessRule=New-Object System.Security.AccessControl.FileSystemAccessRule ($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)
 
$Access.AddAccessRule($FileSystemAccessRule)
 
#Set ACL's on Folder being modified
 SET-ACL $Folder $Access
  
}

#NOTES

#use get-executionpolicy to view what the script execution polily is
#use Set-executionpolicy to set the policy options are Unrestricted | RemoteSigned | AllSigned | Restricted

#The possible values for Rights are 
# ListDirectory, ReadData, WriteData 
# CreateFiles, CreateDirectories, AppendData 
# ReadExtendedAttributes, WriteExtendedAttributes, Traverse
# ExecuteFile, DeleteSubdirectoriesAndFiles, ReadAttributes 
# WriteAttributes, Write, Delete 
# ReadPermissions, Read, ReadAndExecute 
# Modify, ChangePermissions, TakeOwnership
# Synchronize, FullControl