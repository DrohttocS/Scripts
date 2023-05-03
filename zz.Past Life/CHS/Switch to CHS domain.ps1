add-pssnapin quest.activeroles.admanagement
Import-Module ActiveDirectory

$dc = Test-Path -Path CHS:
if(!($dc)){
$username = "CHSspokane\hords"
$password = Get-Content 'C:\admin\RWC_CHS_SecureString.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password


New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsspokane.local" `
    –Credential $cred  `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location CHS:
}



