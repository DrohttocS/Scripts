import-module activedirectory

$username = "chsSpokane\hords"
$password = Get-Content 'C:\admin\securestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password


New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsdc01.CHSSpokane.local" `
    –Credential $cred  `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location CHS:
