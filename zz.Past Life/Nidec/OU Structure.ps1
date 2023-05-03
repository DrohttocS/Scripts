#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


#Create Base OU

$baseOU = 'OU=Dallas-Equinix,OU=AMR,OU=Nidec,DC=nidecds,DC=com' #Read-Host 'Base DN location'
$L1 = 'Accounts','Contacts','Delegation','Groups','Resources'
$AcctOU = 'IT Admins','Service Accounts','Shared Mailboxes','Users'
$Resources = 'Desktops','Laptops','Policy_Exceptions','Servers'
$Policy_Exceptions = 'Desktops','Laptops','Servers'
#region OU Creation
ForEach($OU in $L1){
    try{
    #Get Name and Path from the source file
    $OUName = $OU
    $OUPath = $baseOU
 
    #Display the name and path of the new OU
    Write-Host -Foregroundcolor Yellow "$OUName in $OUPath"
 
    #Create OU

   New-ADOrganizationalUnit -Name "$OUName" -Path "$OUPath" -Credential $AdminCred -PassThru -Server amrndsvpdc03
 
    #Display confirmation
    Write-Host -ForegroundColor Green "OU $OUName created"
    }catch{Write-Host $error[0].Exception.Message}
    }
#region Accounts OU 
ForEach($OU in $AcctOU){
try{
#Get Name and Path from the source file
$OUName = $OU
$OUPath = "OU=Accounts," + $baseOU
 
#Display the name and path of the new OU
Write-Host -Foregroundcolor Yellow "$OUName in $OUPath"
 
#Create OU

New-ADOrganizationalUnit -Name "$OUName" -Path "$OUPath" -Credential $AdminCred -PassThru -Server amrndsvpdc03
 
#Display confirmation
Write-Host -ForegroundColor Green "OU $OUName created"
}catch{Write-Host $error[0].Exception.Message}
} 
#endregion Accounts OU
#region Resources OU 
ForEach($OU in $Resources){
try{
#Get Name and Path from the source file
$OUName = $OU
$OUPath = "OU=Resources," + $baseOU
 
#Display the name and path of the new OU
Write-Host -Foregroundcolor Yellow "$OUName in $OUPath"
 
#Create OU

New-ADOrganizationalUnit -Name "$OUName" -Path "$OUPath" -Credential $AdminCred -PassThru -Server amrndsvpdc03
 
#Display confirmation
Write-Host -ForegroundColor Green "OU $OUName created"
}catch{Write-Host $error[0].Exception.Message}
} 
#endregion Accounts OU
#region Policy_Exceptions OU 
ForEach($OU in $Policy_Exceptions){
try{
#Get Name and Path from the source file
$OUName = $OU
$OUPath = "OU=Policy_Exceptions,"+"OU=Resources," + $baseOU
 
#Display the name and path of the new OU
Write-Host -Foregroundcolor Yellow "$OUName in $OUPath"
 
#Create OU

New-ADOrganizationalUnit -Name "$OUName" -Path "$OUPath" -Credential $AdminCred -PassThru -Server amrndsvpdc03
 
#Display confirmation
Write-Host -ForegroundColor Green "OU $OUName created"
}catch{Write-Host $error[0].Exception.Message}
} 
#endregion Policy_Exceptions OU
#endregion
 
 #region Delegation Account
 $dest = "OU=Delegation," + $baseOU
 $shortname = Read-Host 'Shortname for Delgation Accounts'
 $delegationGroups = 'GroupMgmt','Helpdesk','ServerAdmins','SiteAdmins','UserMgmt','WorkStationAdmin'
 Foreach ($group in $delegationGroups){
 $groupName = "$shortname" + "_" + "$group"
 New-ADGroup -Name $groupName -GroupCategory Security -Path $dest -GroupScope DomainLocal -Credential $AdminCred -PassThru -Server amrndsvpdc03
 }
 $groupName = "$shortname" + "_" + "DivAdmins"
 New-ADGroup -Name $groupName -GroupCategory Security -Path $dest -GroupScope Universal -Credential $AdminCred -PassThru -Server amrndsvpdc03


 #endregion  

$testOU = 'OU=Hoffman Estates,OU=AMR,OU=NIDEC,DC=nidecds,DC=com'



Invoke-Command -ComputerName AMRNDSVPDC01  -ScriptBlock {
$testOU = 'OU=Hoffman Estates,OU=AMR,OU=NIDEC,DC=nidecds,DC=com'
Set-Location AD:
get-acl -Path "OU=Hoffman Estates,OU=AMR,OU=NIDEC,DC=nidecds,DC=com" | fl 