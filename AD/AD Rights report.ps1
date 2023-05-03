# Array for report.
$report = @()
$schemaIDGUID = @{}
# ignore duplicate errors if any #
$ErrorActionPreference = 'SilentlyContinue'
# search OU and account
$User ='LSEMA_SiteAdmins'
$SB = "OU=LS,DC=nidecds,DC=com"

Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
 ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)}
Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
 ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)}
$ErrorActionPreference = 'Continue'
# Get a list of AD objects.
    $AOs += Get-ADObject -SearchBase $SB -SearchScope Subtree -LDAPFilter '(objectClass=*)' | Select-Object -ExpandProperty DistinguishedName
    # Loop through each of the AD objects and retrieve their permissions.
    # Add report columns to contain the path.
    ForEach ($AO in $AOs) {
        $report += Get-Acl -Path "AD:\$AO" |
         Select-Object -ExpandProperty Access | 
         Select-Object @{name='organizationalunit';expression={$AO}}, `
                       @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                       @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                       *
    } # Filter by single user and export to a CSV file.
    
    $report | Where-Object {$_.IdentityReference -like "*$User*"} | Select-Object IdentityReference, ActiveDirectoryRights, OrganizationalUnit, IsInherited -Unique |
    Export-Csv -Path "C:\Users\admshord\Desktop\explicit_permissions.csv" -NoTypeInformation

