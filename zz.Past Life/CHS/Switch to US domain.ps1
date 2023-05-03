add-pssnapin quest.activeroles.admanagement
Import-Module ActiveDirectory
$dc = Test-Path -Path US:
if(!($dc)){
$username = "CHSspokane\hords"
$password = Get-Content 'C:\admin\US_securestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password


New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "us.chs.net" `
    –Credential $cred  `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location US:
}



