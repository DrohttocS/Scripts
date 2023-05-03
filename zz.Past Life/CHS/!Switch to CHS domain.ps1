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