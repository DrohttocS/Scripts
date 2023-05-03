###################################################################################
# Shord 10/7/15
#
# Read First Last Name from Gap list then
#  Disable the account
#  Move account to Disabled OU
#  Tag the account Terminated with Time date stamp
#  Remove all groups except for Domain Users
#
#  Configured for default login AD
#
###################################################################################

# Connect to AD
    import-module activedirectory

# Connect to the BVB Domain
New-PSDrive `
    –Name BVB `
    –PSProvider ActiveDirectory `
    –Server "bvbdc4.bvb.local" `
    –Credential (Get-Credential "bvb\scottadmin") `
    –Root "//RootDSE/" `
    -Scope Global
    Set-Location BVB:


# Set Date Stamp Format
    $TDate = Get-Date -Format g
# Read in Users
#    $Users = Get-Content "c:\admin\GAP_list.txt" #<-- Make sure this file is there.
 $Users = "denbas"
###################################################################################

Foreach ($user in $Users){
Get-ADUser -identity $user  | Set-ADUser -Confirm -Description "TERMINATED - $TDate - sh" -enabled $false -PassThru|`
 Move-ADObject -TargetPath "OU=Disabled User Accounts,DC=bvb,DC=local"
 Remove-ADPrincipalGroupMembership -Identity (Get-ADUser -identity $user)  -MemberOf $(Get-ADPrincipalGroupMembership -Identity (Get-ADUser -identity $user)| Where-Object {$_.Name -ne "Domain Users"}) 
}
