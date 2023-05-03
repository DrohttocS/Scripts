$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


$HVHost01 ="RANUSNDSPPHV02"
$HVHost02 = "RANUSNMCPPHV03"

$srvs2delegate ="Microsoft Virtual System Migration Service/","cifs/","Hyper-V Replica Service/","Microsoft Virtual Console Service/"| sort

$HV01Spns = Foreach ($svs in $srvs2delegate) { $svs + $HVHost01}
$HV02Spns = Foreach ($svs in $srvs2delegate) { $svs + $HVHost02}

$delegationProperty = "msDS-AllowedToDelegateTo"
$delegateToSpns1 = $HV01Spns 
$delegateToSpns2 = $HV02Spns

$HV01Account = Get-ADComputer $HVHost01
$HV02Account = Get-ADComputer $HVHost02


Set-ADAccountControl $HV01Account -TrustedToAuthForDelegation $true -Credential $AdminCred -Server AMRNDSVPDC03 
Set-ADAccountControl $HV02Account -TrustedToAuthForDelegation $true -Credential $AdminCred -Server AMRNDSVPDC03

# Configure Kerberos to (Use any authentication protocol)

$HV01Account | Set-ADObject -Add @{$delegationProperty=$delegateToSpns2} -Credential $AdminCred -Server AMRNDSVPDC03
$HV02Account| Set-ADObject -Add @{$delegationProperty=$delegateToSpns1} -Credential $AdminCred -Server AMRNDSVPDC03


get-adcomputer -Identity $HVHost02 -Properties msDS-AllowedToDelegateTo -Server AMRNDSVPDC03 | select -ExpandProperty msDS-AllowedToDelegateTo


