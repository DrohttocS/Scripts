<#
Ports which needs to be opened for Active directory to function properly
UDP Port 88 for Kerberos authentication
UDP and TCP Port 135 for domain controllers-to-domain controller and client to domain controller operations.
TCP Port 139 and UDP 138 for File Replication Service between domain controllers.
UDP Port 389 for LDAP to handle normal queries from client computers to the domain controllers.
TCP and UDP Port 445 for File Replication Service
TCP and UDP Port 464 for Kerberos Password Change
TCP Port 3268 and 3269 for Global Catalog from client to domain controller.
#>

Function Test-PortConnection {
    [CmdletBinding()]
 
    # Parameters used in this function
    Param
    (
        [Parameter(Position=0, Mandatory = $True, HelpMessage="Provide destination source", ValueFromPipeline = $true)]
        $Destination,
 
        [Parameter(Position=1, Mandatory = $False, HelpMessage="Provide port numbers", ValueFromPipeline = $true)]
        $Ports = "80"
    ) 
 
    $ErrorActionPreference = "SilentlyContinue"
    $Results = @()
 
    ForEach($D in $Destination){
        # Create a custom object
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -Name "Destination" -Value $D
 
        Write-Verbose "Checking $D"
        ForEach ($P in $Ports){
            $Result = (Test-NetConnection -Port $p -ComputerName $D ).TCPTestSucceeded  
 
            If(!$Result){
                $Status = "Failure"
            }
            Else{
                $Status = "Success"
            }
 
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($status)"
        }
 
        $Results += $Object
 
# or easier way true/false value
        ForEach ($P in $Ports){
            $Result = $null
            $Result = Test-NetConnection -Port $p -ComputerName $D -InformationLevel Quiet
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($Result)"
        }
        $Results += $Object
    }
 
# Final results displayed in new pop-up window

   $Results

} 
Test-PortConnection -Destination AMRNDSVPDC03,AMRNDSVPDC01 -Ports 88,135,389,464,3268,3269 | ft

function Test-ServerRolePortGroup {
	<#
	.SYNOPSIS
		This function tests for open TCP/UDP ports by server role.
	.DESCRIPTION
		This function tests for all the approprite TCP/UDP ports by server role so you don't have
		to memorize or look up all of the ports that need to be tested for every time
		you want to verify remote connectivity on a specific server role.
	.NOTES
		Link port references:
		http://technet.microsoft.com/en-us/library/dd772723(v=ws.10).aspx
		http://en.wikipedia.org/wiki/Server_Message_Block
		http://technet.microsoft.com/en-us/library/cc940063.aspx
	.PARAMETER Computername
		One or more remote, comma-separated computer names
	.PARAMETER ServerRole
		The services on the computer that you'd like to find open ports for. This can be
		common services like WinRm, Smb, Dns, Active Directory and NetBIOS
	.EXAMPLE
		PS> Test-ServerRolePortGroup -Computername 'LABDC','LABDC2' -ServerRole NetBIOS,WinRm,Dns
		
		This example tests the network ports necessary for NetBIOS, WinRm and Dns
		to operate on the servers LABDC and LABDC2.
	#>
	
	[CmdletBinding()]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param (
		[Parameter(Mandatory)]
		[ValidateScript({ Test-Connection -ComputerName $_ -Count 1 -Quiet})]
		[string[]]$Computername,
		[Parameter(Mandatory)]
		[ValidateSet('WinRm','Smb','Dns','ActiveDirectoryGeneral','ActiveDirectoryGlobalCatalog','NetBios')]
		[string[]]$ServerRole
	)
	begin {
		$PortGroups = @{
			'WinRm' = @{ 'TCP' = 5985}
			'Smb' = @{ 'TCP' = 445; 'UDP' = 445 }
			'Dns' = @{ 'TCP' = 53; 'UDP' = 53 }
			'ActiveDirectoryGeneral' = @{ 'TCP' = 25, 88, 389, 464, 636, 5722, 9389; 'UDP' = 88,123,389,464 }
			'ActiveDirectoryGlobalCatalog' = @{ 'TCP' = 3268, 3269 }
			'NetBios' = @{ 'TCP' = 135, 137, 138, 139; 'UDP' = 137,138,139 }
		}
	}
	process {
		foreach ($Computer in $Computername) {
			Write-Verbose "Beginning port tests on computer '$Computer'"
			try {
				$TestPortGroups = $PortGroups.GetEnumerator() | where { $ServerRole -contains $_.Key }
				Write-Verbose "Found '$($TestPortGroups.Count)' port group(s) to test"
				foreach ($PortGroup in $TestPortGroups) {
					$PortGroupName = $PortGroup.Key
					$PortGroupValues = $PortGroup.Value
					foreach ($Value in $PortGroupValues.GetEnumerator()) {
						$Protocol = $Value.Key
						$Ports = $Value.Value
						$TestResult = Test-Port -ComputerName $Computer -Protocol $Protocol -Port $Ports
						$TestResult | Add-Member -MemberType 'NoteProperty' -Name 'PortSet' -Value $PortGroupName
						$TestResult
					}
				}
			} catch {
				Write-Verbose "$($MyInvocation.MyCommand.Name) - Computer: $Computer - Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
				$false
			}
		}
	}
}

function Test-Port {
	<#
	.SYNOPSIS
		This function tests for open TCP/UDP ports.
	.DESCRIPTION
		This function tests any TCP/UDP port to see if it's open or closed.
	.NOTES
		Known Issue: If this function is called within 10-20 consecutively on the same port
			and computer, the UDP port check will output $false when it can be
			$true.  I haven't figured out why it does this.
	.PARAMETER Computername
		One or more remote, comma-separated computer names
	.PARAMETER Port
		One or more comma-separated port numbers you'd like to test.
	.PARAMETER Protocol
		The protocol (UDP or TCP) that you'll be testing
	.PARAMETER TcpTimeout
		The number of milliseconds that the function will wait until declaring
		the TCP port closed.
	.PARAMETER
		The number of millieconds that the function will wait until declaring
		the UDP port closed.
	.EXAMPLE
		PS> Test-Port -Computername 'LABDC','LABDC2' -Protocol TCP 80,443
		
		This example tests the TCP network ports 80 and 443 on both the LABDC
		and LABDC2 servers.
	#>
	[CmdletBinding(DefaultParameterSetName='TCP')]
	[OutputType([System.Management.Automation.PSCustomObject])]
	param (
		[Parameter(Mandatory)]
		[string[]]$ComputerName,
		[Parameter(Mandatory)]
		[int[]]$Port,
		[Parameter(Mandatory)]
		[ValidateSet('TCP', 'UDP')]
		[string]$Protocol,
		[Parameter(ParameterSetName='TCP')]
		[int]$TcpTimeout = 1000,
		[Parameter(ParameterSetName = 'UDP')]
		[int]$UdpTimeout = 1000
	)
	process {
		foreach ($Computer in $ComputerName) {
			foreach ($Portx in $Port) {
				$Output = @{ 'Computername' = $Computer; 'Port' = $Portx; 'Protocol' = $Protocol; 'Result' = '' }
				Write-Verbose "$($MyInvocation.MyCommand.Name) - Beginning port test on '$Computer' on port '$Protocol<code>:$Portx'"
				if ($Protocol -eq 'TCP') {
					$TcpClient = New-Object System.Net.Sockets.TcpClient
					$Connect = $TcpClient.BeginConnect($Computer, $Portx, $null, $null)
					$Wait = $Connect.AsyncWaitHandle.WaitOne($TcpTimeout, $false)
					if (!$Wait) {
						$TcpClient.Close()
						Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' failed port test on port '$Protocol</code>:$Portx'"
						$Output.Result = $false
					} else {
						$TcpClient.EndConnect($Connect)
						$TcpClient.Close()
						Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' passed port test on port '$Protocol<code>:$Portx'"
						$Output.Result = $true
					}
					$TcpClient.Close()
					$TcpClient.Dispose()
				} elseif ($Protocol -eq 'UDP') {
					$UdpClient = New-Object System.Net.Sockets.UdpClient
					$UdpClient.Client.ReceiveTimeout = $UdpTimeout
					$UdpClient.Connect($Computer, $Portx)
					Write-Verbose "$($MyInvocation.MyCommand.Name) - Sending UDP message to computer '$Computer' on port '$Portx'"
					$a = new-object system.text.asciiencoding
					$byte = $a.GetBytes("$(Get-Date)")
					[void]$UdpClient.Send($byte, $byte.length)
					#IPEndPoint object will allow us to read datagrams sent from any source.
					Write-Verbose "$($MyInvocation.MyCommand.Name) - Creating remote endpoint"
					$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any, 0)
					try {
						#Blocks until a message returns on this socket from a remote host.
						Write-Verbose "$($MyInvocation.MyCommand.Name) - Waiting for message return"
						$receivebytes = $UdpClient.Receive([ref]$remoteendpoint)
						[string]$returndata = $a.GetString($receivebytes)
						If ($returndata) {
							Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' passed port test on port '$Protocol</code>:$Portx'"
							$Output.Result = $true
						}
					} catch {
						Write-Verbose "$($MyInvocation.MyCommand.Name) - '$Computer' failed port test on port '$Protocol`:$Portx' with error '$($_.Exception.Message)'"
						$Output.Result = $false
					}
					$UdpClient.Close()
					$UdpClient.Dispose()
				}
				[pscustomobject]$Output
			}
		}
	}
}