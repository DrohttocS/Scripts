#Automatically generate the IT_ASSOCIATES distribution list based on direct reports org to CIO
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Get-Module | Remove-Module
Import-Module AzureAD
Import-Module ExchangeOnlineManagement

<# As a scheduled task it's already running as this user.
$Username = "svc-teams@gsfglobal.onmicrosoft.com"
#$password = Get-Content "C:\Scheduled Tasks\Credential\password.txt" | ConvertTo-SecureString -Key (Get-Content "C:\Scheduled Tasks\Credential\aes.key")
$password = @'
pB("16:aAdVKzBUbe7\kxJ~0wn0O'&u*aQBOTu=*k7k"TK>aSTI)N~P45oe[W<}U
'@ | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PsCredential($Username,$password)

Connect-AzureAD -Credential $cred
Connect-ExchangeOnline -Credential $cred
#>

Connect-AzureAD 
Connect-ExchangeOnline 

function Get-AzureADDirectReportsRecursively {
    param (
        [Parameter(Mandatory = $true)]
        [String]$UserObjectId
    )

    # Get the user's direct reports
    $directReports = Get-AzureADUserDirectReport -ObjectId $UserObjectId

    if ($directReports) {
        # Iterate through each direct report
        foreach ($directReport in $directReports) {
            # Get the direct report's details and output the UserPrincipalName
                Get-AzureADUser -ObjectId $directReport.ObjectId | Select-Object -ExpandProperty UserPrincipalName
            # Recursively call the function for the direct report
                Get-AzureADDirectReportsRecursively -UserObjectId $directReport.ObjectId 
        }
    }
}

# Carol Fawcett
$userId = "4ea29986-fbfd-4301-8d65-d573636024a8"

# Get the direct reports recursively and sort the results
$Results = Get-AzureADDirectReportsRecursively -UserObjectId $userId | Sort-Object

# Other users required to be in the list
$Others = "LCerpa-Smith@goldenstatefoods.com","rmurray@goldenstatefoods.com",'CFawcett@Goldenstatefoods.com'

# Combine the results and additional users
$FinalResults = $Results + $Others

# Update the distribution group members
Update-DistributionGroupMember -Identity 'IT_Associates' -Member $FinalResults -Confirm:$false

Disconnect-AzureAD
Disconnect-ExchangeOnline