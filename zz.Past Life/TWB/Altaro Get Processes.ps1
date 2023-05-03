#######
#  
#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password

$dc = "twb-backup"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Invoke-Command -ComputerName $dc -Credential $AdminCred -ScriptBlock {
 Set-Location  "C:\Program Files\Altaro\Altaro Backup\Cmdlets"
 .\set-token.ps1
$token = Get-Content  -path C:\Support\tolkien.txt
$serviceAddress = "https://localhost:35113/api"

#status /activity/operation-status/{sessionToken}
    $operationGuid = $args[1]
    $uriOptionalPart = "";
    if (![string]::IsNullOrEmpty($operationGuid))
    {$uriOptionalPart = '/' + $operationGuid}
    $uri = $serviceAddress + "/activity/operation-status/" + $token + $uriOptionalPart
    $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" 
    $json = $result | ConvertTo-Json
    $currentops = $json | ConvertFrom-Json | select -ExpandProperty Statuses | Select-Object JobId,Operation,Percentage,status,SubOperation 
    cls;Write-host " Currently there are" $currentops.Count "process running"
    $currentops |ft -AutoSize -Wrap
# CLOSE Session
    $uri = $serviceAddress + "/sessions/end"
    $disco = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" 
    } 
   