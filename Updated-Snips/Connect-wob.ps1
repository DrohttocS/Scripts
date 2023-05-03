import-module activedirectory

New-PSDrive `
    –Name WOB `
    –PSProvider ActiveDirectory `
    –Server "westonebank.local" `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location WOB: