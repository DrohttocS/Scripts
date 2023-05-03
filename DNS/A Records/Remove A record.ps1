#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$pDNS = 'AMRNDSVPDC03'

Clear-Host

# Connect and remove DNS
Invoke-Command -ComputerName $pDNS -Credential $AdminCred -ScriptBlock{
$defaultZone = 'nidecds.com'
$NodeDNS = $null
$NodeToDelete = Read-Host "Please Input the Name of the A Record you want to delete. NO FQDN"
$DNSServer = 'AMRNDSVPDC03'
($defaultZone,(Read-Host "Enter domain zone. [$($defaultZone)]")) -match '\S' |% {$ZoneName = $_}
$NodeDNS = Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $NodeToDelete -RRType A -ErrorAction SilentlyContinue

if($NodeDNS -eq $null){
    Write-Host "The DNS A Record You Were Looking For Was Not Found!" -ForeGroundColor Red
} else {
    Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -InputObject $NodeDNS -Force
    Write-Host "Your DNS A Record $NodeToDelete Has Been Removed" -ForeGroundColor Green
  

 $NodeDNS  = $NodeDNS | out-string
# Ticket Info

    $tic ="`n`nHi,
    I've removed the requested DNS A record for $NodeToDelete.
    
    $NodeDNS 
    
    The requested change is currently replicating.
    

    
    Regards,
    Scott"
    $tic
  }}


