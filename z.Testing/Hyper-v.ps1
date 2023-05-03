
function List-hyperVHosts {            
  [cmdletbinding()]            
  param(
  	[string]$forest
  )            
  try {            
   Import-Module ActiveDirectory -ErrorAction Stop            
  } catch {            
   Write-Warning "Failed to import Active Directory module. Cannot continue. Aborting..."            
   break;
  }            

  $domains=(Get-ADForest -Identity $forest).Domains 
  foreach ($domain in $domains){
  #"$domain`: `n"
  [string]$dc=(get-addomaincontroller -DomainName $domain -Discover -NextClosestSite).HostName
  try {             
   $hyperVs = Get-ADObject -Server $dc -Filter 'ObjectClass -eq "serviceConnectionPoint" -and Name -eq "Microsoft Hyper-V"' -ErrorAction Stop;
  } catch {            
   "Failed to query $dc of $domain";         
  }            
  foreach($hyperV in $hyperVs) {            
     $x = $hyperV.DistinguishedName.split(",")            
     $HypervDN = $x[1..$x.Count] -join ","  
      
     if ( !($HypervDN -match "CN=LostAndFound")) {     
     $Comp = Get-ADComputer -Id $HypervDN -Prop *
     $OutputObj = New-Object PSObject -Prop (
     @{
     HyperVName = $Comp.Name
     OSVersion = $($comp.operatingSystem)
     })
     $OutputObj
     }           
   }
   }
}

function listForests{
	$GLOBAL:forests=Get-ADForest | select Name;
	if ($forests.length -gt 1){
		#for ($i=0;$i -lt $forests.length;$i++){$forests[$i].Name;}
		$forests | %{$_.Name;}
	}else{
		$forests.Name;
	}
}

function listHyperVHostsInForests{
	listForests|%{List-HyperVHosts $_}
}

$hVserv = listHyperVHostsInForests
$hVserv = $hVserv.HyperVname

############################################################################

$listOfComputers = $hVserv
# code to execute remotely
$code = {

Get-VMHostSupportedVersion

}
# invoke code on all machines
$VMinfo = Invoke-Command -ScriptBlock $code2 -ComputerName $listOfComputers -Throttle 1000

$VMinfo | sort PSComputerName
$vms = $VMinfo.name


foreach($serv in $vms){
 Write-Host "Starting on $serv"  
 Get-WindowsFeature -ComputerName ABB-NACT01-0420  | Where-Object {$_.Installed -match $True} | Select-Object "DisplayName"

 }
 Invoke-Command -ScriptBlock $code -ComputerName twb-ucshost3
 Invoke-Command -ScriptBlock {get-vm} -ComputerName twb-llohost3