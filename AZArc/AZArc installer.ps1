try {
    # Add the service principal application ID and secret here
    $servicePrincipalClientId="83977492-9d67-4a87-ad17-6c80ef21b634";
    $servicePrincipalSecret="WH58Q~b0oYmrb1eBP02pf.QxRATJV38nFeed7buK";

    $env:SUBSCRIPTION_ID = "2fbb3361-4b3a-46c3-963e-546c6ba3a992";
    $env:RESOURCE_GROUP = "EUS-PROD-ARC";
    $env:TENANT_ID = "7cd55b73-e7ef-4c98-9bba-20ea620bd692";
    $env:LOCATION = "eastus";
    $env:AUTH_TYPE = "principal";
    $env:CORRELATION_ID = "d3c018f9-1329-4f66-825a-e7c5d212b50c";
    $env:CLOUD = "AzureCloud";

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    # Download the installation package
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/azcmagent-windows" -TimeoutSec 30 -OutFile "$env:TEMP\install_windows_azcmagent.ps1";

    # Install the hybrid agent
    & "$env:TEMP\install_windows_azcmagent.ps1";
    if ($LASTEXITCODE -ne 0) { exit 1; }

    # Run connect command
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --service-principal-id "$servicePrincipalClientId" --service-principal-secret "$servicePrincipalSecret" --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --tags "Datacenter=Equinix" --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId="$env:SUBSCRIPTION_ID";resourceGroup="$env:RESOURCE_GROUP";tenantId="$env:TENANT_ID";location="$env:LOCATION";correlationId="$env:CORRELATION_ID";authType="$env:AUTH_TYPE";operation="onboarding";messageType=$_.FullyQualifiedErrorId;message="$_";};
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
