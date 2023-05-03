#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password
$O365Creds = Get-StoredCredential -Target "$env:USERNAME-O365"


# import the Azure Active Directory module in order to be able to use Get-AzureADUserMembership and Add-AzureADGroupMember cmdlet
import-Module AzureAD

Connect-AzureAD -Credential $O365Creds

# enter login name of the first user
$user1 = Read-host "Enter username to copy from: "

# enter login name of the second user
$user2  = Read-host "Enter username to copy to: " 

# Get ObjectId based on username of user to copy from and user to copy to
$user1Obj = Get-AzureADUser -ObjectID $user1
$user2Obj = Get-AzureADUser -ObjectID $user2


$membershipGroups = Get-AzureADUserMembership -ObjectId $user1Obj.ObjectId

Write-Host "\-- Groups available to copy from" $user1 to $user2 "--\" -ForegroundColor Yellow

foreach($group in $membershipGroups) {
Write-Host $group.DisplayName
Write-Host "[!] - Adding" $user2Obj.UserPrincipalName " to " $group.DisplayName "... " -ForegroundColor Yellow -nonewline
Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $user2Obj.ObjectId
Write-Host "Done"
}


