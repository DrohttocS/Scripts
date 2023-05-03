import-module activedirectory

New-PSDrive `
    –Name BVB `
    –PSProvider ActiveDirectory `
    –Server "bvb.local" `
  #  –Credential (Get-Credential "bvb\scottadmin") `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location BVB: