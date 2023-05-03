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
$Fvref = $failed.AltaroVirtualMachineRef
# Restart systems
    foreach($vmid in $Fvref){
    $uri = "$serviceAddress/instructions/take-backup/$token/$vmid"
    $result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body (ConvertTo-Json $body) 
    }
#update Ticket 
    $rstatus =@()
    $RScount =   $failed.count
    $SucCount =  $success.count
    $restart = $failed  | select VirtualMachineName, LastBackupTime
    $restart | ft -AutoSize -Wrap
        $rstatus += "$RScount Backups Restarting.`r`n"
        $rstatus += "$SucCount Backups ran clean.`r`n"
        $rstatus += $restart | Out-String
$encodedCredentials = "YnZiXHNob3JkMjEyNjpEcmFnMG5hc3Mh"
$headers = @{ Authorization = "Basic $encodedCredentials" }
$body = $rstatus
Write-Host "Updating ticket.`n$rstatus"
 #update a tickets comments
 $baseurl = "https://helpdesk.trailwest.bank"
 $api ="/api/Tickets?statusID=1"
 $url = $baseurl+$api
$HDTicket = Invoke-WebRequest -Uri $url -Method Get -Headers $headers
$hdt = $HDTicket | ConvertFrom-Json 
$ticketNum = $hdt | ?{$_.subject -like "Altaro VM Backup: TWB-BACKUP*"} | select IssueID
$ticketNum = $ticketNum.IssueID
$ticket = $ticketNum

# enter comment

 $api ="/api/comment?id=$ticket&Body=$body"
 $url = $baseurl+$api
 $HD = Invoke-WebRequest -Uri $url -Method post -Headers $headers 

# CLOSE Session
Write-Host "Disco from API"
$uri = $serviceAddress + "/sessions/end"
$result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" 
}
