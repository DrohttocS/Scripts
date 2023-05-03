# Loop through the CSV
    foreach ($group in $groups) {

    $groupProps = @{

      Name          = $group.name
      Path          = $group.path
      GroupScope    = $group.scope
      GroupCategory = $group.category
      Description   = $group.description

      }#end groupProps

    New-ADGroup @groupProps
    
} #end foreach loop

$OrganizationalUnit = "OU=Servers,OU=SP02,OU=Delivery,$rootDN"
$ServiceUserName = "account_name"
Set-Location AD:
$Group = Get-ADuser -Identity $ServiceUserName
$GroupSID = [System.Security.Principal.SecurityIdentifier] $Group.SID
$ACL = Get-Acl -Path $OrganizationalUnit
$Identity = [System.Security.Principal.IdentityReference] $GroupSID
$Computers = [GUID]"bf967a86-0de6-11d0-a285-00aa003049e2"
$ResetPassword = [GUID]"00299570-246d-11d0-a768-00aa006e0529"
$ValidatedDNSHostName = [GUID]"72e39547-7b18-11d1-adef-00c04fd8d5cd"
$ValidatedSPN = [GUID]"f3a64788-5306-11d1-a9c5-0000f80367c1"
$AccountRestrictions = [GUID]"4c164200-20c0-11d0-a768-00aa006e0529"
$RuleCreateAndDeleteComputer = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, "CreateChild, DeleteChild", "Allow", $Computers, "All")
$RuleResetPassword = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($Identity, "ExtendedRight", "Allow", $ResetPassword, "Descendents", $Computers)
$RuleValidatedDNSHostName = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($GroupSID, "Self", "Allow", $ValidatedDNSHostName, "Descendents", $Computers)
$RuleValidatedSPN = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($GroupSID, "Self", "Allow", $ValidatedSPN, "Descendents", $Computers)
$RuleAccountRestrictions = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($Identity, "ReadProperty, WriteProperty", "Allow", $AccountRestrictions, "Descendents", $Computers)
$ACL.AddAccessRule($RuleCreateAndDeleteComputer)
$ACL.AddAccessRule($RuleResetPassword)
$ACL.AddAccessRule($RuleValidatedDNSHostName)
$ACL.AddAccessRule($RuleValidatedSPN)
$ACL.AddAccessRule($RuleAccountRestrictions)
Set-Acl -Path $OrganizationalUnit -AclObject $ACL

 $OrganizationalUnit = "OU=Test,DC=Contoso,DC=COM"
 $GroupName = "Domain Users"
    
 Set-Location AD:
 $Group = Get-ADGroup -Identity $GroupName
 $GroupSID = [System.Security.Principal.SecurityIdentifier] $Group.SID
 $ACL = Get-Acl -Path $OrganizationalUnit
    
 $Identity = [System.Security.Principal.IdentityReference] $GroupSID
 $ADRight = [System.DirectoryServices.ActiveDirectoryRights] "GenericAll"
 $Type = [System.Security.AccessControl.AccessControlType] "Allow"
 $InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
 $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $ADRight, $Type,  $InheritanceType)
    
 $ACL.AddAccessRule($Rule)
 Set-Acl -Path $OrganizationalUnit -AclObject $ACL