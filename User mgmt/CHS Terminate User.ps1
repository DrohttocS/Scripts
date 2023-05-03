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
$dc = Test-Path -Path CHS:
if(!($dc)){
function Import-Credential 
{
   param
   (
     [Parameter(Mandatory=$true)]
     $Path
   )
    
  $CredentialCopy = Import-Clixml $path    
  $CredentialCopy.password = $CredentialCopy.Password | ConvertTo-SecureString    
  New-Object system.Management.Automation.PSCredential($CredentialCopy.username, $CredentialCopy.password)
}


$cred = Import-Credential -Path C:\admin\CHS_SecureString.txt
New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsspokane.local" `
    –Credential $cred  `
    –Root "//RootDSE/" `
    -Scope Global

    
}
Set-Location CHS:


# Connect to AD
    import-module activedirectory
# Set Date Stamp Format
    $TDate = Get-Date -Format g
# Read in Users
#    $Users = Get-Content "c:\admin\GAP_list.txt" #<-- Make sure this file is there.
 $Users = "denbas"
###################################################################################

Foreach ($user in $Users){
Get-ADUser -identity $user  | Set-ADUser -Confirm -Description "TERMINATED - $TDate" -enabled $false -PassThru|`
 Move-ADObject -TargetPath "OU=Disabled Users,DC=CHSspokane,dc=local"
 Remove-ADPrincipalGroupMembership -Identity (Get-ADUser -identity $user)  -MemberOf $(Get-ADPrincipalGroupMembership -Identity (Get-ADUser -identity $user)| Where-Object {$_.Name -ne "Domain Users"}) 
}
