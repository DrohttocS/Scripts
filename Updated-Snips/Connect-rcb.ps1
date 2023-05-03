import-module activedirectory

New-PSDrive `
    –Name RCB `
    –PSProvider ActiveDirectory `
    –Server "rcbank.local" `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location RCB: