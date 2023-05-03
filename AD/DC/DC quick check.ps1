<#
	.SYNOPSIS
		Get AD Health and replication
	
	.DESCRIPTION
		Runs DC Diag and replication summary
	
	.EXAMPLE
				PS C:\> Get-DCStatus
	
	.NOTES
		Additional information about the function.
#>
function Get-DCStatus
{
	####################Netlogons status##################
	$netlogonT = dcdiag /test:netlogons | select-string -Pattern "test NetLogons" | out-string
	$netlogonT = ($netlogonT).replace('.', '')
	$netlogonT = $netlogonT -split ' '
	$netlogonT = $netlogonT[11]
	####################Replications status##################
	$ReplicationT = dcdiag /test:Replications | select-string -Pattern " test Replications" | out-string
	$ReplicationT = ($ReplicationT).replace('.', '')
	$ReplicationT = $ReplicationT -split ' '
	$ReplicationT = $ReplicationT[11]
	####################Services status##################
	$ServicesT = dcdiag /test:Services | select-string -Pattern " test Services" | out-string
	$ServicesT = ($ServicesT).replace('.', '')
	$ServicesT = $ServicesT -split ' '
	$ServicesT = $ServicesT[11]
	####################Advertising status##################
	$AdvertisingT = dcdiag /test:Advertising | select-string -Pattern " test Advertising" | out-string
	$AdvertisingT = ($AdvertisingT).replace('.', '')
	$AdvertisingT = $AdvertisingT -split ' '
	$AdvertisingT = $AdvertisingT[11]
	####################Intersite status##################
	$IntersiteT = dcdiag /test:Intersite | select-string -Pattern " test Intersite" | out-string
	$IntersiteT = ($IntersiteT).replace('.', '')
	$IntersiteT = $IntersiteT -split ' '
	$IntersiteT = $IntersiteT[11]
	####################KccEvent status##################
	$KccEventT = dcdiag /test:KccEvent | select-string -Pattern " test KccEvent" | out-string
	$KccEventT = ($KccEventT).replace('.', '')
	$KccEventT = $KccEventT -split ' '
	$KccEventT = $KccEventT[11]
	####################Topology status###################
	$TopologyT = dcdiag /test:Topology | select-string -Pattern " test Topology" | out-string
	$TopologyT = ($TopologyT).replace('.', '')
	$TopologyT = $TopologyT -split ' '
	$TopologyT = $TopologyT[11]
       <#####################SystemLog status##################
         $SystemLogT = dcdiag /test:SystemLog | select-string -Pattern " test SystemLog" | out-string
         $SystemLogT = ($SystemLogT).replace('.','')
         $SystemLogT = $SystemLogT -split ' '
         $SystemLogT = $SystemLogT[11]
        ####################KnowsOfRoleHolders status##################>
	$KnowsOfRoleHoldersT = dcdiag /test:KnowsOfRoleHolders | select-string -Pattern "Starting test: KnowsOfRoleHolders" -Context 0, 2 | out-string
	$KnowsOfRoleHoldersT = ($KnowsOfRoleHoldersT).replace('.', '')
	$KnowsOfRoleHoldersT = $KnowsOfRoleHoldersT -split ' '
	$KnowsOfRoleHoldersT = $KnowsOfRoleHoldersT[24]
	######################################################
	$srvsNotRunning = Get-Service | where{ $_.StartType -eq "Automatic" } | ? { $_.Status -ne "running" } | select DisplayName -ExpandProperty DisplayName
	$SWagent = Get-Service "solar*"
	if ([string]::IsNullOrWhiteSpace($SWagent)) { $SWagent = 'Not Installed' }
	else { $SWagent = Get-Service "solar*" | select Status -ExpandProperty Status }
	$lastHotfix = ((get-hotfix).properties | where { $_.name -eq "installedon" }).value
	$lhd = Foreach ($date in $lastHotfix) { [datetime]$date }
	$lastHotfix = $lhd | sort | select -Last 1
	$Rapid7Srv = Get-Service "ir_agent" -ErrorAction SilentlyContinue
	if ([string]::IsNullOrWhiteSpace($Rapid7Srv)) { $Rapid7Srv = 'Not Installed' }
	else { $Rapid7Srv = Get-Service "ir_agent*" | select Status -ExpandProperty Status }
	$system = Get-WmiObject win32_operatingsystem
	$NumberOfLogicalProcessors = (Get-WmiObject -class Win32_processor | Measure-Object -Sum NumberOfLogicalProcessors).Sum
	$Installed = Get-CimInstance -ClassName win32_product | select name -ExpandProperty name
	$cs = $Installed -contains "CrowdStrike Sensor Platform"
	$Duo = $Installed -contains "Duo Authentication for Windows Logon x64"
	$Rapid7 = $Installed -contains "Rapid7 Insight Agent"
	$land = $Installed -contains "LANDESK Advance Agent"
	New-Object PSObject -Property ([ordered]@{
			Identity			   = $ENV:COMPUTERNAME
			'Checking AD Services' = '+-+-+-+'
			"Netlogon Service"	   = get-service -Name "Netlogon" -ErrorAction SilentlyContinue | select -ExpandProperty status
			"AD Services"		   = get-service -Name "NTDS" -ErrorAction SilentlyContinue | select -ExpandProperty status
			"DNS Service Status"   = get-service -Name "DNS" -ErrorAction SilentlyContinue | select -ExpandProperty status
			#'Rapid7 Service Status' = '+-+-+-+-+-+-+-+'
			#'Rapid7 Agent Status'  = $Rapid7Srv
			'Checking DC Diag'	   = '+-+-+-+'
			"Net logon"		       = $netlogonT
			"Replication"		   = $ReplicationT
			"Services"			   = $ServicesT
			"Advertising"		   = $AdvertisingT
			"Intersite"		       = $IntersiteT
			"KCC"				   = $KccEventT
			"Topology"			   = $TopologyT
			"FSMO"				   = $KnowsOfRoleHoldersT
			#'Checking SoftWare compliance ' = '+-+-+-+'
			#'Crowd Strike'		   = $cs
			#'Duo Authentication'   = $Duo
			#"Rapid7 Insight Agent" = $Rapid7
			#"LANDESK Advance Agent" = $land
			'Stopped srvs '	       = '+-+-+-+-+-+-+-+-+-+-+-+'
			"AutoStart"		       = $srvsNotRunning | Out-String
			"SolarWinds Agent"	   = $SWagent
			"Last Hot Fix"		   = $lastHotfix.ToShortDateString()
			"Reboot Status"	       = $system.ConvertToDateTime($system.LastBootUpTime)
			"CPU Status"		   = (Get-Counter '\Process(*)\% Processor Time').Countersamples | Where cookedvalue -gt ($NumberOfLogicalProcessors * 10) | Sort cookedvalue -Desc | ft -a instancename, @{ Name = 'CPU %'; Expr = { [Math]::Round($_.CookedValue / $NumberOfLogicalProcessors) } } | Out-String
		})
}
Function ListDcs{Get-ADDomainController -Filter * | select Name -ExpandProperty name }

$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$ISECred = Get-StoredCredential -Target "$env:USERNAME-ise"
$dcs = ListDcs
$men2= @();$menu = @{}
for ($i=1;$i -le $dcs.count; $i++) {
  # Write-Host "$i. $($dcs[$i-1].name )" -ForegroundColor Green
    $men2 += New-Object PSObject -Property ([ordered]@{
                TheThing          = "$i. $($dcs[$i-1].name )" 
        })
     $menu.Add($i,($dcs[$i-1].name)) 
    }



$men2 | Format-Wide -Column 2 -Force 
[int]$ans = Read-Host "`nEnter selection"
$selection = $menu.Item($ans)
Invoke-Command -ComputerName $selection -Credential $AdminCred -ScriptBlock ${function:Get-DCStatus}