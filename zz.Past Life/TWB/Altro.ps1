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
# Creds 
$Credential = Import-Credential -Path "C:\Support\sa.txt"
Start-Process powershell -Credential $Credential -ArgumentList "Start-Process -FilePath "C:\Program Files\Altaro\Altaro Backup\ManagementTools\Altaro.ManagementConsole.exe"  