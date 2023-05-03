$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
#admbmaanikam

#region Gather Info

$newADM = Read-Host 'Enter Non ADM Account Name (First Last)'
$firstname,$lastname = $newADM –split ' '
$newADM =  Get-ADUser -Filter "GivenName -eq '$FirstName' -and Surname -eq '$LastName'" | select -First 1
$TemplateAcct = 'admbmaanikam'
$TemplateAcct = Get-ADUser -Identity $TemplateAcct -Properties * | select name,GivenName,Surname,SamaccountName,DisplayName,UserPrincipalName,DistinguishedName ,Enabled,Description,MemberOf
$Tdisplay = $TemplateAcct.DisplayName
$ou = $newADM.DistinguishedName.Split(',',4)[3]
$email = $newADM.EmailAddress
$subJ = $newADM.GivenName + " " + $newADM.Surname

#endregion

$confirmation = "Is this the correct user account $firstname $lastname`nIn OU:`n $ou"
 



Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::YesNo
$MessageIcon = [System.Windows.MessageBoxImage]::Question
$MessageBody = $confirmation
$MessageTitle = "Create ADM account for $firstname $lastname"
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
Write-Host "Your choice is $Result"

if($Result -eq 'Yes'){
#region Create new ADM account 
            $Path = $TemplateAcct.DistinguishedName.Split(',',3)[2]
            $Name = "$firstname $lastname - ADM" 
            $GivenName = $firstname
            $Surname = "$lastname - ADM"
            $SamAccountName = "ADM"+ $firstname.Substring(0,1) + $lastname
            $DisplayName = "$lastname, $firstname - ADM"
            $UserPrincipalName = "ADM"+ $firstname.Substring(0,1) + $lastname + '@nidecds.com'
            $Enabled = $true
            $AccountPassword = (ConvertTo-SecureString 'Poweredge01' -AsPlainText -Force) 
            $ChangePasswordAtLogon = $true
            $Server = 'AMRNDSVPDC03'

$newADM  = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"
if($null -ne $newADM){ write-host "Account already in AD" 
break   
}else{
 write-host "SamAccountName $SamAccountName does NOT exist in active directory. Creating account`n$SamAccountName ... " 
}

New-ADUser -Credential $AdminCred `
           -Name $Name `
           -GivenName $GivenName `
           -Surname $Surname `
           -SamAccountName $SamAccountName `
           -DisplayName $DisplayName `
           -UserPrincipalName $UserPrincipalName `
           -Enabled $true `
           -ChangePasswordAtLogon $true `
           -Server $Server `
           -Path $Path `
           -AccountPassword (ConvertTo-SecureString 'Poweredge01' -AsPlainText -Force) 

Sleep 2
$CopyToUser = Get-ADUser $SamAccountName -prop MemberOf -Server $Server
$TemplateAcct.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser -Credential $AdminCred -Server $Server

#endregion

$tic="

Email: $email
SUBJECT Line: New ADM Account for $subJ


Hi $firstname,

I've created you a new ADM account.

You must login into a LOCAL machine first and update your password to activate your account.

UserName = $SamAccountName
Password = Poweredge01 

If you have any issues please let me know.

Thanks,
Scott


"

$tic}else{break}
