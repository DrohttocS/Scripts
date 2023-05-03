$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$svr = Get-ADComputer -Filter {OperatingSystem -like "*Server*" -and enabled -eq $true}  | select -ExpandProperty Name
$svr.Count
#check if Svr is up
    $isup   = @()
    $isDown = @()

$svr| ForEach {
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

$PSWINRMt1 = $PSWINRM |Select -ExpandProperty ComputerName 
$TR1 = foreach($LA in $PSWINRMt1){
 Invoke-Command  $LA -Credential $AdminCred  -ScriptBlock {
        Try{
            $members = net localgroup administrators |
                where {$_ -AND $_ -notmatch "command completed successfully"} | select -skip 4
       }Catch{
             Write-Warning "Opps"
}
  New-Object PSObject -Property @{
     Computername = $env:COMPUTERNAME
     Group = "Administrators"
     Members= $members                            

}
}
}
$Tr1 | ft -AutoSize -Wrap

# post processing

$G = $TR1 |select -Last 1

$list=@()
$list += Foreach($member in $G){

    Foreach($LAcct in $member.Members){
            if ($LAcct -like "nish*"){
            $dom = 'NISH'
            $user = $LAcct.Split("\")[-1]
            }
        Else {
            $dom = 'Local'
            $user = $LAcct
        }
        New-Object PSObject -Property @{
             Computername = $member.Computername
             Group = $member.Group
             Domain = $dom
             User =   $user                         
        }

}
}
$list | ft -AutoSize -Wrap
$list | Export-Csv -Path c:\temp\LocalAdmin.csv
