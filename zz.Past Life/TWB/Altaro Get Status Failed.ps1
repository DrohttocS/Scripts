#######
#  
#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$dc = "twb-backup"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Invoke-Command -ComputerName $dc -Credential $AdminCred -ScriptBlock {
 #$ticketID = Read-Host "Ticket Number"
 Set-Location  "C:\Program Files\Altaro\Altaro Backup\Cmdlets"
.\set-token.ps1
$token = Get-Content  -path C:\Support\tolkien.txt
$serviceAddress = "https://localhost:35113/api"
#Get Backup Success/Fails 
$configuredOnly = 1
$uriOptionalPart = "";
if (![string]::IsNullOrEmpty($configuredOnly)){$uriOptionalPart = '/' + $configuredOnly}
$uri = $serviceAddress + "/vms/list/" + $token + $uriOptionalPart
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" 
$json = $result | ConvertTo-Json 
$failed = $json | ConvertFrom-Json |select -ExpandProperty VirtualMachines|?{($_.LastBackupResult -eq  "failed")}
$success = $json | ConvertFrom-Json |select -ExpandProperty VirtualMachines|?{($_.LastBackupResult -eq  "success")}
$fc = $failed.count
$sc = $success.count


Cls
$body =@()
$BODY +=  "$fc Backups failed Last night.`r`n"
$BODY +=  "$sc Backup were Successful.`r`n"
$BODY +=  $failed | select  VirtualMachineName,HostName, LastBackupResult, LastBackupTime| sort LastBackupResult, HostName, LastBackupTime, VirtualMachineName | ft | Out-String 
$body
$success |select  VirtualMachineName, LastBackupResult, LastBackupTime| sort LastBackupResult, LastBackupTime, VirtualMachineName |ft

$encodedCredentials = "YnZiXHNob3JkMjEyNjpEcmFnMG5hc3Mh"
$headers = @{ Authorization = "Basic $encodedCredentials" }
$body = $body 

 #update a tickets comments
 $ticket = Read-Host "Ticket Number"

 $baseurl = "https://helpdesk.trailwest.bank"
 $api ="/api/comment?id=$ticket&Body=$body"
 $url = $baseurl+$api
 $HD = Invoke-WebRequest -Uri $url -Method post -Headers $headers 
 

# CLOSE Session
Write-Host "Disco from API"
$uri = $serviceAddress + "/sessions/end"
$result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" 
}
