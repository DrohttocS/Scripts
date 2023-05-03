#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
# Enter-PSSession AMRNDSVPDC03 -Credential $AdminCred


$rawSubnets = Invoke-Command -ComputerName saeqdc01 -Credential $AdminCred -ScriptBlock{
$date = Get-Date -Format "MM/dd" 
$header = "Date","Time","Unknown","Domain","Error","PC","IP"
$unknown = gc C:\Windows\debug\netlogon.log | ConvertFrom-Csv -Delimiter " " -Header $header
$raw = $unknown  | ? {$_.date -eq $date}
$IP = $raw | select -ExpandProperty IP | % {$_.split('.')[0..2] -join '.'}| select -Unique

#$IP = $unknown | ConvertFrom-Csv -Delimiter " " -Header $header | select -ExpandProperty IP | % {$_.split('.')[0..2] -join '.'}| select -Unique
$Subnets = $ip | foreach { $_ +  '.0' }
$Subnets
}
$rawSubnets

$rcount = $rawSubnets.Count
$ipam = Import-Csv "C:\Users\nmc77pw\Documents\projects\Sites and Subnets\IPAM Report.csv"
$newKnownSubnets = $ipam | ?{$rawSubnets -match $_.address -and $_.type -ne 'group'} | ft
$foundcount = $newKnownSubnets.Count

write-host "There are $rcount Unknown Subnets in the list."
Write-host "We Found info on $foundcount of those subnets."

$DcList = (Get-ADForest).Domains | ForEach { Get-ADDomainController -Discover -DomainName $_ } | ForEach { Get-ADDomainController -Server $_.Name -filter * } | Select Site, Name, ipv4address





$ipam | Out-GridView












foreach ($network in $newKnownSubnets){

$Subobj = New-Object PSObject
$Subobj | Add-Member -type NoteProperty -name "Subnet"  -Value $Subnet.Name

    $RA = 
    $RA | Add-Member -type NoteProperty -name "Subnet"  
    $RA | Add-Member -type NoteProperty -name "Site" -Value $SiteName

}

$newKnownSubnets

foreach($subnet in $missing){
New-ADReplicationSubnet -Name $subnet.subnet -Site $subnet.site -Description $subnet.Description -Server AMRNDSVPDC03 -Verbose -Credential $AdminCred
}




