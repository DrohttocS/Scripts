$Table = import-csv -Path "C:\Users\wcw101934\Wawa Inc\Identity & Access Management - AD-CleanupActivities - Documents\AD-CleanupActivities\ServerAdminRights_Cleanup\EveryLastAdmin.csv"
$Table = import-csv -Path "C:\temp\EveryLastAdmin.csv" 
$Table = $Table | ?{$_.server -ne "WSRV5151"} # Remove Wsrv5151 - old citrix srv

$res = foreach($item in $Table){
$group = $item.admin.Trim()
$svr = $item.server.Trim()
$srvW = $item | Select admin,server | ?{$group -like "*_LocalAdmin" -and  $group -like "*$svr*"}
    New-Object PSObject -Property ([ordered]@{
        User = $item.user
        Server = $svr
        Group = $group
        IsCorrect = if ($srvW -ne $null){'Good'}else{'Bad'}
        })
} 

$good = $res | ?{$_.isCorrect -eq 'Good'}
$bad = $res | ?{$_.isCorrect -eq 'bad'}
$badLA = $res | ?{$_.isCorrect -eq 'bad' -and $_.Group  -like "*Wsrv*_LocalAdmin"}
$GS = $good | select server -ExpandProperty server -Unique
$BSvr = $bad | select server -ExpandProperty server -Unique

$BSvr = $BSvr |? { $GS -notcontains $_ }
#Clean the list
$BSvr = $BSvr |? {$_ -notlike "*Temp*"}

$WSR_BSvr =  $BSvr  |? {$_  -Like "WSRV*" }
$Test_BSVR =$WSR_BSvr | select -First 2 # Test on two servers to verify.


$res = foreach($LA in $Test_BSVR){
$prefix = "LA_"
$Suffix = "_LocalAdmin"
$New_LA_Group = $prefix+$LA+$Suffix
$DoesITExsist = $null
$DoesITExsist = [bool](Get-ADGroup $New_LA_Group )
$DoesITExsist = if($DoesITExsist -eq $true){Get-ADGroup $New_LA_Group -Properties Created}else{''}
# Testing 

  New-Object PSObject -Property ([ordered]@{
            Srv = $LA
            LAGroup  = if([string]::IsNullOrWhiteSpace($DoesITExsist)){'NO LA Group'}Else{$DoesITExsist.created} 
 }) 
 }
 $res | Out-GridView


Write-Host "Creating group $New_LA_Group"
New-ADGroup -Name $New_LA_Group -GroupScope Universal -GroupCategory Security -Path "OU=LocalAccessGroups,OU=AllGroups,DC=WAWA,DC=com" -Description "Local Admin Group for $la" 
}






$Test_BSVR = 'WSRV5814'
#Create Groups All the Group
foreach($LA in $Test_BSVR){
$prefix = "LA_"
$Suffix = "_LocalAdmin"
$New_LA_Group = $prefix+$LA+$Suffix
Write-Host "Creating group $New_LA_Group"
New-ADGroup -Name $New_LA_Group -GroupScope Universal -GroupCategory Security -Path "OU=LocalAccessGroups,OU=AllGroups,DC=WAWA,DC=com" -Description "Priv Role, grants Local admin access to $la" 
}


CN=LA_WSRV5900_LocalAdmin,OU=LocalAccessGroups,OU=AllGroups,DC=WAWA,DC=com

# Only Apply the groups to the WSVR systems
check if Svr is up
$isup   = @()
$isDown = @()

#WSRV Filter 
$WSR_BSvr =  $BSvr  |? {$_  -Like "WSRV*" }
$Test_BSVR =$WSR_BSvr | select -First 2 # Test on two servers to verify.
$Test_BSVR| ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            $isUP += $_
            Write-Host "$_ is online."            
                    } else 
                    { Write-Warning "$_ Not online or accessable."
            $isDown += $_
                    }     
}

#Connect to Server and add group to local
    
    foreach($LA in $isUP){
    Write-Host "Attempting to con"
    $results = Invoke-Command $LA  -ScriptBlock {
                            Add-LocalGroupMember -Group "Administrators" -Member "corporate\$using:New_LA_Group"
                            Get-LocalGroupMember -Group administrators
}
}




