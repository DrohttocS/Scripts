$DeletedComputerName="XWMLSCEB1068"
$DeletedComputer = Get-ADObject -LDAPFilter "CN=$DeletedComputerName*" -IncludeDeletedObjects -properties whenChanged
$BitLocker = Get-ADObject -Filter {objectClass -eq 'msFVE-RecoveryInformation'} -IncludeDeletedObjects -Properties LastKnownParent,'msFVE-RecoveryPassword' | ? {$_.LastKnownParent -eq "$($DeletedComputer.DistinguishedName)"}
$BitLocker | Restore-ADObject -Credential $AdminCred

