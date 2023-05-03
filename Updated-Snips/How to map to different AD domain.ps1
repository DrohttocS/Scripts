import-module activedirectory

New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsdc01.CHSSpokane.local" `
    –Credential (Get-Credential "chsSpokane\hords") `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location CHS: