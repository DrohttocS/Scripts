If (!(Test-Path CHS:))
{
import-module activedirectory

New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsdc01.CHSSpokane.local" `
    –Credential (Get-Credential "chsSpokane\hords") `
    –Root "//RootDSE/" `
    -Scope Global

    Set-Location CHS:
}

## This variable gets all the users that are in Group1
$Group1 = (Get-ADGroup 'Managed_DMC_User').DistinguishedName

## This variable gets all the users that are in Group2
$Group2 = (Get-ADGroup 'Managed_VHMC_User').DistinguishedName

## This variable gets all the users that are in Group3
$Group3 = (Get-ADGroup 'MANAGED_RHS_TERM').DistinguishedName

## This variable gets all the users that are in Group4
$Group4 = (Get-ADGroup 'MANAGED_VHMC_TERM').DistinguishedName


$userGroups = Get-ADUser -Filter {(memberOf -ne $Group1) -AND (memberOf -ne $Group2) -AND (memberOf -ne $Group3) -AND (memberOf -ne $Group4)}
$userGroups | Out-GridView
($userGroups | Measure-Object).Count