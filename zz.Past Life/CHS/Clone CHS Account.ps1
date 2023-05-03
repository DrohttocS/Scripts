Import-Module ActiveDirectory
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

$CloneAC = Read-Host "Account to clone from: "
$user2copy = Get-ADUser -identity $CloneAC
$pcname = Read-Host "Account to clone to: "
#Remove-ADPrincipalGroupMembership -Identity (Get-ADUser -Identity $pcname )  -MemberOf $(Get-ADPrincipalGroupMembership -Identity (Get-ADUser -Identity $pcname )| Where-Object {$_.Name -ne "Domain Users"}) 
$CopyFromUser = Get-ADUser $user2copy -prop MemberOf
$CopyToUser = Get-ADUser $pcname -prop MemberOf
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser
 