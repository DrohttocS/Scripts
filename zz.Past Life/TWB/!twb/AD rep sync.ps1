$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
Enter-PSSession -ComputerName twb-dc1 -Credential $AdminCred



function Replicate-AllDomainController {
(Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess
}

Exit-PSSession 