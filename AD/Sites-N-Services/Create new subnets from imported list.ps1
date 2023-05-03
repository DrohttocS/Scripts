$VlanSubnets = Import-Csv -Path "C:\Users\shord\OneDrive - Red River Technology LLC\Documents\SA Docs\Network VLans-Subnets.csv"
$VlanSubnets | select -last 2 | ft -AutoSize -Wrap

$currentSubnets = Get-ADReplicationSubnet -Filter * |?{$_.Location -eq $null}  | select -ExpandProperty Name

$currentSubnets.Count
$VlanSubnets.Count

New-ADReplicationSubnet -Name "192.168.57.0/24" -Credential $AdminCred -Location Test -Site Azure-INFPROD -Description "blah blah" -force

foreach($Subnet in $VlanSubnets){
    
    Try{
        New-ADReplicationSubnet -Name $Subnet.subnet -Location $Subnet.Location -Site $Subnet.Site -Description $Subnet.Description  -Credential $AdminCred -PassThru -ErrorAction Stop

    }
    Catch{
        Set-ADReplicationSubnet -Identity $Subnet.Subnet -Location $Subnet.Location -Site $Subnet.Site -Description $Subnet.Description -Credential $AdminCred -PassThru
    }
    }


$2fix =  
$VlanSubnets | ?{$_.subnet -match $currentSubnets}