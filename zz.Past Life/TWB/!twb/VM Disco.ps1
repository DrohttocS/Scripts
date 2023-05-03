$isUP =@()
$isDown =@()
$Computer=@()
$vm=@()
$feat=@()
#$ErrorActionPreference = 'silentlycontinue'
Foreach ($Computer in $allsys)
{
    #Ping Test. If PC is shut off, script will stop for the current PC in pipeline and move to the next one.
    if (Test-Connection -ComputerName $Computer.FQDN -Count 1 -Quiet)
    {
        # do productive stuvv here
        
        $isUP += $Computer
    } else {
        # do error (no connection available) stuff here
        
        $isDown +=$Computer
    } 
    } # bottom of foreach loop


$isUP = $isUP | sort ServiceConnectionPoint, FQDN

    cls
foreach($vm in $isUP){

### $VM.Features of interest  ##
$Feat = 

Get-WindowsFeature -ComputerName $vm.Name | ? { $_.Installed -and $_.PostConfigurationNeeded -eq $false} | Select-Object displayName,name 

#|`
#        Where-Object {$_.displayname -match "Active Directory Certificate Services|Certification Authority|Active Directory Domain Services|^RAS.*$|DHCP Server|DNS Server|Failover Clustering|Data Deduplication|DFS Namespaces|DFS Replication|File Server|Group Policy Management|Hyper-V|Message Queuing Server|Multipath I/O|Network Policy and Access Services|Remote Access|SMTP Server|WSUS Services|Volume Activation Services|Windows Internal Database|Windows Server Backup" } |`
#        Foreach {$Matches[0]} |  sort -Unique 

$vm.Features = $feat| %{ "`t`t" + $_ } | Out-String

###  $VM.Role ######
if ($vm.IsSql.Equals($true)){$vm.Role += 'MS SQL '} 
if ($vm.IsExchange.Equals($true)){$vm.Role += 'Exchange '} 
# if ($vm.IsHyperVhost.Equals($true)){$vm.Role += 'Hyper-V Host '} 
if ($vm.IsHyperVcluster.Equals($true)){$vm.Role += 'Hyper-V Cluster '} 
if ($vm.IsDC.Equals($true)){$vm.Role += 'DC '} 
if ($vm.IsADConnect.Equals($true)){$vm.Role += 'Azure Connected Host '} 
# if ($vm.IsRDSLicense.Equals($true)){$vm.Role += 'RDP Enabled '} 
if ($vm.IsFile.Equals($true) -and  $vm.IsDC.Equals($false) -and $vm.IsSql.equals($False) -and $vm.IsExchange.equals($False)){$vm.Role += 'File Server '} 








if ($vm.Role.Length -le 1){$vm.Role += 'Unknown'} 


##########        #output
Write-Host `r`n
write-host "Server Name:"$VM.name "`t`t`t`t`tIP:" $vm.IPv4
Write-Host "Server Type:" $VM.ServiceConnectionPoint `t`t`t"OS:" $vm.OperatingSystem
Write-Host "Roles:" $vm.Role 
Write-Host "Installed Features:" 
            $feat | %{ "`t`t" + $_ } | Out-String
}

