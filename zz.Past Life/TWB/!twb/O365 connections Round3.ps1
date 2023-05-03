#  Install-Module -Name CredentialManager
# New-StoredCredential -Comment 'O365' -Credentials $(Get-Credential) -Target 'ScottAdmin' -Type DomainPassword -Persist LocalMachine
# Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password

$Cred = Get-StoredCredential -Target OnMicrosoft
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential (Get-StoredCredential -Target OnMicrosoft) -Authentication Basic -AllowRedirection

# Connect to Msol
    Connect-MsolService -Credential $Cred
    Import-PSSession $Session -DisableNameChecking

cls
$user = Read-Host -Prompt "Enter the First intial and the last 4 of the lastname."
$user = "$user*"
$user = Get-ADUser -Server twb-dc1 -Filter {samaccountname -like $user} -Properties * -SearchBase "OU=Family of Banks Users,DC=bvb,DC=local"
$UMan = $user.manager
$UMan = ($UMan -split ',*..=')[1]

$dblc = $user.Name
$user = $user.SamAccountName
$upn = "$user@trailwest.bank"


# Covert mailbox to share
    Set-Mailbox $upn -Type Shared
# Set permission
    Add-MailboxPermission -Identity $dblc -User $UMan -AccessRights Fullaccess -InheritanceType all
# Remove License
    (get-MsolUser -UserPrincipalName $upn).licenses.accountskuid | Set-MsolUserLicense $upn -RemoveLicenses $_
# Block sign in
    Set-MsolUser -UserPrincipalName $upn -BlockCredential $true