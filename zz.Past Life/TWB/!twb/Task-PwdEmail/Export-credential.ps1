function Export-Credential 
{
   param
   (
     [Parameter(Mandatory=$true)]
     $Path,

     [System.Management.Automation.Credential()]
     [Parameter(Mandatory=$true)]
     $Credential
   )
    
  $CredentialCopy = $Credential | Select-Object *    
  $CredentialCopy.Password = $CredentialCopy.Password | ConvertFrom-SecureString    
  $CredentialCopy | Export-Clixml $Path
} 