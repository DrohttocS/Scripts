$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$dhcpsrv = Get-DhcpServerInDC | sort DnsName

$men2= @()
$menu = @{}
for ($i=1;$i -le $dhcpsrv.count; $i++) {
  # Write-Host "$i. $($dhcpsrv[$i-1].DnsName )" -ForegroundColor Green
    $men2 += New-Object PSObject -Property ([ordered]@{
            TheThing          = "$i. $($dhcpsrv.DnsName[$i-1])" 
        })
     $menu.Add($i,($dhcpsrv[$i-1].DnsName))
    }

$men2 | Format-Wide -Column 4 -Force
[int]$ans = Read-Host "`nEnter selection"
$selection = $menu.Item($ans) 
Invoke-Command -ComputerName $selection -Credential $AdminCred -ScriptBlock{
        $Scopes = Get-DhcpServerv4Scope #| ?{$_.state -eq 'Active'}
    $res =     foreach($scope in $Scopes){
      $stats =    Get-DhcpServerv4ScopeStatistics -ScopeId $scope.ScopeId

              New-Object PSObject -Property ([ordered]@{
                    'DHCP Server'        = $ENV:COMPUTERNAME
                        ScopeId = $Scope.scopeId
                        SubnetMask = $scope.SubnetMask
                        Name = $scope.Name
                        State = $scope.State
                        StartRange = $scope.StartRange
                        EndRange  = $scope.EndRange
                        LeaseDuration = $scope.LeaseDuration
                        Free = $stats.Free
                        InUse = $stats.InUse
                        PercentageInUse = $stats.PercentageInUse
                        Reserved = $stats.Reserved
                        Pending = $stats.Pending
                        

                })
            Get-DhcpServerv4Scope | Get-DhcpServerv4Reservation 
         }

$res | ft -AutoSize -Wrap

}



