$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
#admgsedmach

#region Gather Info

$newADM = Read-Host 'Enter Non ADM Account Name (First Last)'
$firstname,$lastname = $newADM –split ' '
$newADM =  Get-ADUser -Filter "GivenName -eq '$FirstName' -and Surname -eq '$LastName'" | select -First 1
$Access = Read-Host 'server Access'
#$TemplateAcct = Get-ADUser -Identity $TemplateAcct -Properties * | select name,GivenName,Surname,SamaccountName,DisplayName,UserPrincipalName,DistinguishedName ,Enabled,Description,MemberOf
#$Tdisplay = $TemplateAcct.DisplayName
$ou = $newADM.DistinguishedName.Split(',',4)[3]
$email = $newADM.UserPrincipalName
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
            $Path = "OU=IT ADMINS," + $ou 
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
            $Description = ""

$newADM  = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"
if($null -ne $newADM){ write-host "Account already in AD" 
break   
}else{
 write-host "SamAccountName $SamAccountName does exist in active directory. Creating account`n$SamAccountName ... " 
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
#$CopyToUser = Get-ADUser $SamAccountName -prop MemberOf -Server $Server
#$TemplateAcct.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser -Credential $AdminCred -Server $Server

#endregion

$tic="

Email: $email
SUBJECT Line: New ADM Account for access to $Access


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


<#
$admaccount = Get-ADUser $SamAccountName -Server $Server 
$dn = $admaccount.DistinguishedName

$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$div ='+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+'
$men2= @()
$menu = @{}
for ($i=1;$i -le $dcs.count; $i++) {
  # Write-Host "$i. $($dcs[$i-1].name )" -ForegroundColor Green
    $men2 += New-Object PSObject -Property ([ordered]@{
            TheThing          = "$i. $($dcs[$i-1].name )" 
        })
     $menu.Add($i,($dcs[$i-1].name))
    }

$men2 | Format-Wide -Column 4 -Force

[int]$ans = Read-Host "`nEnter selection"
$selection = $menu.Item($ans) 

# Sync-ADObject -Object $dn -Source $Server -Destination $selection -Credential $AdminCred

#>