$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$wsvr = Get-ADComputer -Filter {OperatingSystem -like "*Server*" -and enabled -eq $true}  | select -ExpandProperty Name
$wsvr.Count
#check if Svr is up
    $isup   = @()
    $isDown = @()

$wsvr| ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            $isUP += $_
            Write-Host "$_ is online."            
                    } else 
                    { 
            Write-Warning "$_ Not online or accessable."
            $isDown += $_
                    }     
}

Write-host "Up count: "$isup.count 
Write-host "Down count: "$isDown.count
Write-host "Testing WSMan(PS) access."

$PSAccess = $isup | Test-NetConnection  -CommonTCPPort WINRM
$PSAccess | Export-Csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\PowerShell Acl.csv"  -NoTypeInformation

$PSWINRM = $PSAccess | ?{$_.TcpTestSucceeded -eq $true}
$NOWINRM = $PSAccess | ?{$_.TcpTestSucceeded -ne $true}

$PSWINRM.count
$NOWINRM.count

$PSWINRMt1 = $PSWINRM |Select -ExpandProperty ComputerName -First 15
$TR1 = foreach($LA in $PSWINRMt1){
    Invoke-Command  $LA -Credential $AdminCred  -ScriptBlock {
        Try{
                        Get-LocalGroup -group administrators
                       # Add-LocalGroupMember -Group "Administrators" -Member "corporate\$using:New_LA_Group"
            
            
       }Catch{
       <#
       

                                # Get members of specific group
                                ## Get Administrators group
                                $Administrators = Get-LocalGroup -SID 'S-1-5-32-544'
                                ## Get group members
                                $null = Add-Member -InputObject $Administrators -MemberType 'NoteProperty' -Force -Name 'Members' -Value (
                                    [string[]](
                                        $(
                                            [adsi](
                                                'WinNT://{0}/{1}' -f $env:COMPUTERNAME, $Administrators.'Name'
                                            )
                                        ).Invoke(
                                            'Members'
                                        ).ForEach{
                                           $([adsi]($_)).'path'.Split('/')[0]
                                            $([adsi]($_)).'path'.Split('/')[-1]
                                        }
                                    )
                                )
                                ## Output members
                               $LAG =  $Administrators.Members| Out-String
                               New-Object PSObject -Property ([ordered]@{
                                        Srv = $env:COMPUTERNAME
                                        Domain = $LAG
                                        LAGroup  = $LAG
                                }) 
                                #>
                Write-Warning "Crap"
            }
}
}

$Tr1 | ft -AutoSize -Wrap


$LA = net localgroup administrators

$groups = Get-CimInstance -ClassName Win32_Group -Filter "LocalAccount='True'" | Select-Object -Property Name
ForEach ($group in $groups) {
    $members = $([ADSI]"WinNT://$($env:COMPUTERNAME)/$($group.Name)").members() | % {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    ForEach ($member in $members) {
        $local = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount='True'" | Select-Object -Property Name | Where-Object Name -eq $member
        if ($local) {"This is the local group: $($group.Name) and this is the local account: $($local.Name)"} else {}
    }
}

SASPTSTAPP0206\Administrator
7iL5)J-}D(0a