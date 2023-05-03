$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$DaysInactive = 190
$time = (Get-Date).Adddays(-($DaysInactive)) 
$srvs = Get-ADComputer -Filter {whenChanged -ge $time -and enabled -eq $true -and OperatingSystem -Like '*Server*' } |select -ExpandProperty name | sort 



Function Get-Complaince{
$required_apps = "Local Administrator Password Solution","Qualys Cloud Security Agent","Dell SecureWorks Red Cloak","Azure Connected Machine Agent","Kaseya Live Connect"
$Installed = Get-CimInstance -ClassName win32_product | ?{$_.name -in $required_apps}
$Installed = $Installed | select -ExpandProperty name
$missing = $required_apps | ?{$_ -notin $Installed}
$mo = $missing | Out-String

<# if([string]::IsNullOrWhiteSpace($missing)){Write-Host -ForegroundColor Green $env:COMPUTERNAME":`tPASSED"}Else{Write-Warning $env:COMPUTERNAME":`tFailed Complaince Validation";Write-Host "Missing:";$missing }

    If($missing -contains "Azure Connected Machine Agent") {
      try { $servicePrincipalClientId="65395333-492c-49b8-8292-1057b08bb8cc"; $servicePrincipalSecret="yV68Q~L8MFHtv9~ydg~u~CbmeGoHSefZk_gRpby-"; $env:SUBSCRIPTION_ID = "aad0644b-aa6f-4e18-80b4-cbee146e58eb"; $env:RESOURCE_GROUP = "DefaultResourceGroup-EUS"; $env:TENANT_ID = "7cd55b73-e7ef-4c98-9bba-20ea620bd692"; $env:LOCATION = "eastus"; $env:AUTH_TYPE = "principal"; $env:CORRELATION_ID = "72cdd973-5d53-48b7-9754-a08f88a606dd"; $env:CLOUD = "AzureCloud"; [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1"; & "$env:TEMP\install_windows_azcmagent.ps1"; if ($LASTEXITCODE -ne 0) { exit 1; } & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$servicePrincipalClientId" --service-principal-secret "$servicePrincipalSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --tags "Datacenter=Equinix,azUpdates='Group 1',Owner,Environment,Role" --correlation-id "$env:CORRELATION_ID"; } catch { $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";}; Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null; Write-Host -ForegroundColor red $_.Exception; }
#>
  	New-Object PSObject -Property ([ordered]@{
			Identity			   = $ENV:COMPUTERNAME
            Compliant = if([string]::IsNullOrWhiteSpace($missing)){"PASSED"}Else{"Failed"}
            Missing = $missing | Out-String
            })


#}  end if
}#end fun

$res = Invoke-Command -ComputerName $srvs -Credential $AdminCred -ScriptBlock ${function:Get-Complaince}


$res |ft -AutoSize -Wrap