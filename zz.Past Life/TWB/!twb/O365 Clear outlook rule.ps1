####### Pre-req ###########
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Comment 'O365' -Credentials $(Get-Credential) -Target $env:USERNAME -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
#
# Let's Store your credentials - Enter your username and the app password


$Cred = Get-StoredCredential -Target $env:USERNAME
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential (Get-StoredCredential -Target $env:USERNAME) -Authentication Basic -AllowRedirection
# Connect to Msol
    Connect-MsolService -Credential $Cred
    Import-PSSession $Session -DisableNameChecking

$user = Read-Host -Prompt "Enter the First intial and the last 4 of the lastname."
$user = "$user*"
$user = Get-ADUser -Server twb-dc1 -Filter {samaccountname -like $user} -Properties * # -SearchBase "OU=Family of Banks Users,DC=bvb,DC=local"
$upn = $user.UserPrincipalName
$upn

# get inbox rules.
Get-InboxRule  -Mailbox $upn  | Select Name, Description,RuleIdentity,MailboxOwnerId | Ft -AutoSize -Wrap

#remove inbox rules
Remove-InboxRule -Identity 9560742057257992193 -Mailbox $upn

# Disable-InboxRule -Identity <rule_name> -Mailbox <mailbox_name>