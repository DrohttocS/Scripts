Set-Location  "C:\Program Files\Altaro\Altaro Backup\Cmdlets"
$token = ""
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

if (Test-Path ServiceAddress.txt)
{
    $serviceAddress = Get-Content ServiceAddress.txt
}
else
{
    $serviceAddress = "https://localhost:35113/api";
}

$username = "scottadmin"
$password = "Drag0nass2bvb!"
$domain = "bvb"
$serverPort = $args[3]
$serverAddress = $args[4]

if ([string]::IsNullOrEmpty($serverPort))
{
    $serverPort = "35107"
}

if ([string]::IsNullOrEmpty($serverAddress))
{
    $serverAddress = "LOCALHOST"
}

$body = @{
                ServerAddress = $serverAddress; 
                ServerPort = $serverPort; 
                Username = $username; 
                Password = $password; 
                Domain = $domain
         }

$uri = $serviceAddress + "/sessions/start"
$result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body (ConvertTo-Json $body) 

$json = $result | ConvertTo-Json
Write-Host $json

$result.Data
$token =  $result.Data


if (Test-Path ServiceAddress.txt)
{
    $serviceAddress = Get-Content ServiceAddress.txt
}
else
{
    $serviceAddress = "https://localhost:35113/api";
}

#$token = $args[0]
$configuredOnly = 1
$uriOptionalPart = "";

if (![string]::IsNullOrEmpty($configuredOnly))
{
    $uriOptionalPart = '/' + $configuredOnly
}

$uri = $serviceAddress + "/vms/list/" + $token + $uriOptionalPart
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" 

$json = $result | ConvertTo-Json 
$backups = $json | ConvertFrom-Json |select -ExpandProperty VirtualMachines|?{$_.LastBackupResult -eq  "failed"}|Select-Object AltaroVirtualMachineRef,VirtualMachineName,LastBackupResult,LastBackupTime| sort LastBackupResult,VirtualMachineName
Cls
$backups


# current operations
$operationGuid = $args[1]
$uriOptionalPart = "";
if (![string]::IsNullOrEmpty($operationGuid))
{$uriOptionalPart = '/' + $operationGuid}
$uri = $serviceAddress + "/activity/operation-status/" + $token + $uriOptionalPart
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" 
$json = $result | ConvertTo-Json
$currentops = $json | ConvertFrom-Json | select -ExpandProperty Statuses | Select-Object JobId,Operation,Percentage,SubOperation
$currentops

<#
$body = @{
                altaroVirtualMachineRef = $serverAddress; 
                ServerPort = $serverPort; 
                Username = $username; 
                Password = $password; 
                Domain = $domain
         }

$uri = $serviceAddress + "/sessions/start"
$result = Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body (ConvertTo-Json $body) 

#>
#POST /instructions/take-backup/{token}/{altaroVirtualMachineRef}


$VMREF = "3f249894-b365-4027-894d-11319014b630"  # $backups.AltaroVirtualMachineRef
$uri = $serviceAddress + "instructions/take-backup/" + $token + '/' + $VMREF
$result = Invoke-RestMethod -Uri $uri -Method Post  -ContentType  "application/json" -Body(ConvertTo-Json $body)


# Get backup locations
$includeBackupLocations = 1
$includeOffsiteLocations = 0

$uriOptionalPart = "";

if (![string]::IsNullOrEmpty($includeBackupLocations))
{
    $uriOptionalPart = '/' + $includeBackupLocations 
}

if (![string]::IsNullOrEmpty($includeOffsiteLocations))
{
    $uriOptionalPart = '/' + $includeBackupLocations +'/' + $includeOffsiteLocations
}

$uri = $serviceAddress + "/backuplocations/" + $token + $uriOptionalPart
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" 

$json = $result | ConvertTo-Json
$Nas = $json | ConvertFrom-Json |select -ExpandProperty BackupLocations 
$nas = $nas | select LocationPath,BackupLocationId

## Get Verions capable of restore



$altaroVirtualMachineRef = "428c6912-3c0f-4391-a52e-9735770dc9ed"
$backupLocationId = "d9ff4bd8-970f-453f-8179-11cdf2e7f2d7"

$uri = $serviceAddress + "/restore-options/available-versions/" + $token + '/' + $altaroVirtualMachineRef + '/' + $backupLocationId;
$result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" 

$r2r  = $result | ConvertTo-Json
$dates = $r2r | ConvertFrom-Json |select -ExpandProperty VirtualMachineRestoreDetails | select HostName,VirtualMachineName,Versions
$dates



# CLOSE Session
$uri = $serviceAddress + "/sessions/end"
Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" 
#
