<# 
REQUIRED FILTERS:
Column: MB, Filter OUT all users that have a Y
Column: "Salary or Hourly Code", Filter OUT all users that are S (only H)

 Azure AD Get-AzureADUser -Filter "employeeId eq '36392'" | fl
 On-prem EmployeeID get-aduser -Filter {EmployeeID -eq '36392'}

 Get-MgUser -UserId 174a6447-cd03-4c2c-bb9f-b3b6ebe865f3 -Property SignInActivity | Select-Object -ExpandProperty SignInActivity | select -Last 1 LastSignInDateTime 

#>

$license = $User| Get-AzureADUserLicenseDetail | select -ExpandProperty SkuPartnumber
$groupMembership = Get-AzureADUserMembership -ObjectId $user.ObjectId
    $groupAName = 'Licensed_Hourly_Users'
    $groupBName = 'Licensed_E3_Hourly_Exceptions'
    # Check if the user is a member of Group A
    $inGroupA = $groupMembership | Where-Object { $_.ObjectType -eq "Group" -and $_.DisplayName -eq $groupAName }
    # Check if the user is a member of Group B
    $inGroupB = $groupMembership | Where-Object { $_.ObjectType -eq "Group" -and $_.DisplayName -eq $groupBName }
    # Output the user's group membership
     if ($inGroupA -and $inGroupB) {
        $BothG = 'X' 
    } elseif ($inGroupA) {
        $AGroup = 'X' 
    } elseif ($inGroupB) {
        $Bgroup = 'X'
    }


Function On-Prem {
       [CmdletBinding()]
   Param
    (
         [Parameter(ValueFromPipeline)]       
         [string] $eid
      )
Begin {
Write-Host "Checking EID against on prem AD."
}
Process{
Try{
$User = Get-ADUser -Filter {EmployeeID -eq $eid} -Properties DisplayName,LastLogonDate,EmployeeID,EmailAddress,UserPrincipalName,mail,mailnickname -ErrorAction Stop


$a = $User.samaccountName
$GroupMembership = Get-ADPrincipalGroupMembership $a  | select -ExpandProperty name
$b = $User.enabled
$c = $User.EmployeeID
$d = $User.LastLogonDate
$e = $User.mail
$f = $User.UserPrincipalName
$h = $GroupMembership |  Out-String
$i = $User.DisplayName
$j = $User.mailNickname


New-Object PSObject -Property ([ordered]@{
    DisplayName = $i
    SamAccountName = $a
    Enabled = $b
    EMP_ID = $c
    LastLogon = $d
    Email = $e
    UPN = $f
    Groups = $h
})


}
Catch{
Write-Warning "Crap"
}
}
}
Function Check-AzureAD {
       [CmdletBinding()]
   Param
    (
         [Parameter(ValueFromPipeline)]       
         [string] $eid
      )
Begin {
Write-Host "Checking EID against Azure AD."
}
Process{
Try{
# Correct for leading zeros
$padLength = 5
$paddedEid = $eid.PadLeft($padLength, '0')

# Output the padded EID
$eid = $paddedEid

$User = Get-AzureADUser -Filter "employeeId eq '$eid'"

$a = $User.ObjectId
$b = $User.AccountEnabled
$c = $User.ExtensionProperty.employeeId
$d = $User.RefreshTokensValidFromDateTime
$e = $User.UserPrincipalName
$f = $User.UserPrincipalName
$h = $GroupMembership |  Out-String
$i = $User.DisplayName
$j = $User.mailNickname
$k = 

New-Object PSObject -Property ([ordered]@{
    DisplayName = $i
    ObjectID = $a
    Enabled = $b
    EMP_ID = $c
    LastLogon = $d
    Email = $e
    UPN = $f

})


}
Catch{
Write-Warning "Crap"
}
}
}