#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


Enter-PSSession -ComputerName SATPDHCP01 -Credential $AdminCred


$failocerScopes = Get-DhcpServerv4Failover 

$res =@()
$res += foreach($scope in $failocerScopes){



        New-Object PSObject -Property ([ordered]@{
            "Name"					=$scope."Name"
            "PartnerServer"			=$scope."PartnerServer"
            "Mode"					=$scope."Mode"
            "LoadBalancePercent"	=$scope."LoadBalancePercent"
            "ServerRole"			=$scope."ServerRole"
            "ReservePercent"		=$scope."ReservePercent"
            "MaxClientLeadTime"		=$scope."MaxClientLeadTime"
            "StateSwitchInterval"	=$scope."StateSwitchInterval"
            "State"					=$scope."State"
            "ScopeId"				=$scope."ScopeId" | select -ExpandProperty IPAddressToString| sort |Out-String
            "AutoStateTransition"	=$scope."AutoStateTransition"
            "EnableAuth"			=$scope."EnableAuth"
        })


}
$res |select Name,PartnerServer, Mode, scopeid |sort PartnerServer|?{$res.scopeid -ne ""} | ft -AutoSize -Wrap



Exit-PSSession


