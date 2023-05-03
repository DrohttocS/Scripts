#######
#  Disable User in AD & O365
#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-O365" -Persist Enterprise
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
#  Install-Module -Name ExchangeOnlineManagement
# Store your credentials - Enter your username and the app password

$fS = "\\twb-files\UserDocs\"
$dc = "twb-dc1"
$O365Cred = Get-StoredCredential -Target "$env:USERNAME-O365"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$user = Read-Host -Prompt "Enter the First intial and the last 4 of the lastname."
$user = "$user*"
$user = Get-ADUser -Server $dc -Filter {samaccountname -like $user} -Properties * -SearchBase "OU=Family of Banks Users,DC=bvb,DC=local"
$UMan = ($user.manager -split ',*..=')[1]
$UManD = $user.manager
$dblc = $user.Name
$upn = $user.UserPrincipalName
$user = $user.SamAccountName
$TDate = Get-Date -Format g
$manDrive = Get-ADUser -Identity $UMand
$manDrive = $manDrive.samaccountname
$upath = $fs+$user
$manpath = $fs+$manDrive

#####
# Pre-flight Check list
#####
Write-host "Is this the right User :$dblc `n`n "
if ([string]::IsNullOrEmpty($UManD))
{
   Write-Host 'Please update Manager field in AD' -ForegroundColor white -BackgroundColor red
   Break
}

Pause
#######################################################################################################################
##
## Office 365 cleanup for term user
##
#######################################################################################################################

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $O365Cred -Authentication Basic -AllowRedirection
# Connect to Msol
    Connect-MsolService -Credential $O365Cred
    Import-PSSession $Session -DisableNameChecking
# Covert mailbox to share
    Set-Mailbox $upn -Type Shared 
# Set permission
    Add-MailboxPermission -Identity $dblc -User $UMan -AccessRights Fullaccess -InheritanceType all
# Block sign in
    Set-MsolUser -UserPrincipalName $upn -BlockCredential $true 
# Remove License  
    $skuID = (get-MsolUser -UserPrincipalName $upn).licenses.accountskuid
    Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $skuID
# End O365 Session
    Remove-PSSession $Session

#####
# AD Termination
#####
    
 $s = New-PSSession -ComputerName $dc -Credential $AdminCred
 Enter-PSSession -session $s
 # Doing stuff    
     Add-ADGroupMember  -Identity DisabledUsers -Members $user 
     Get-ADUser -identity $user  | Set-ADUser  -Description "TERMINATED - $TDate by  $adminu" -enabled $false -PassThru  |`
     Move-ADObject  -TargetPath "OU=Disabled User Accounts,DC=bvb,DC=local"
     get-aduser $user  |  Set-ADObject   -replace @{primaryGroupID=6193}
     Remove-ADPrincipalGroupMembership -Identity $user -MemberOf $(Get-ADPrincipalGroupMembership   -Identity $user | Where-Object {$_.Name -ne "DisabledUsers"}) 
     # Check group status
     cls;Write-host "Checking Group Status. `n`n"
     Get-ADPrincipalGroupMembership -Identity $user | select name,GroupCategory| sort GroupCategory,Name | ft -AutoSize -Wrap

# Set up User Home Dir copy
#update ownership of Favorites folder - Folder redirection broke permissions
       icacls "$upath\favorites" /reset /t /c
if(Test-Path -Path $upath){
    Write-Host "Found $dblc Home folder.`n`nCheckings for MGRs Homedrive."
    If(Test-Path -Path $manpath){
    Write-Host "`n`nFound $manDrive home Dir.`n`nStartinging to copy."
    Copy-Item -Path $upath -Destination $manpath -PassThru -Recurse -WhatIf
#remove H drive
    Remove-Item -Path $upath -Force  
    }
  ELSE{ Write-Host 'Cant find MGR home Dir'}}
  else{Write-Host "Can't locate homefolder for $user"}


Exit-PSSession
