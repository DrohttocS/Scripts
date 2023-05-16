Connect-MsolService
Connect-AzureAD
Connect-MgGraph
Connect-MgGraph -ClientID f324340f-1589-43ea-b7c0-9e7552bca398 -TenantId c6cb47f3-d8a4-47d0-8139-b43165edd882

# A36392@gsfglobal.onmicrosoft.com

 Get-MgUser -UserId ff16350e-d394-4a97-aa93-33292681cfbf -Property SignInActivity | Select-Object -ExpandProperty SignInActivity | select -Last 1 LastSignInDateTime 

cls
$TheList = Import-Csv -Path 'C:\pstemp\User_Security_Provisioning_with derived User Name.csv' 
Write-Host "Raw list count:" $TheList.count

$filteredList = $TheList #| ?{$_."MB Flag" -ne "Y" -and $_."Salary Or Hourly Code" -eq "H"}
Write-Host "Filtered list count:" $filteredList.count



$test = $filteredList  #| select -First 20
$res = foreach($upn in $test){
# Initialize variables for this user
    $BothG = $null
    $AGroup = $null
    $Bgroup = $null
    $license = $null
    $OID = $null
Try{

$User = Get-AzureADUser -ObjectId $upn.'Email Address' -ErrorAction Stop 
$OID = $User.ObjectId
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

New-Object PSObject -Property ([ordered]@{
ObjectID = $OID
"SKU" = $license -join ', '
"Lic hrly" = $AGroup
"Lic Ex" = $Bgroup
"Both" = $BothG
"Enabled" = $User.AccountEnabled
"Employee Number" = $UPN."Employee Number"
"First Name" = $UPN."First Name"
"Preferred" = $UPN."Preferred"
"Last Name" = $UPN."Last Name"
"Work Phone" = $UPN."Work Phone"
"Work Extension" = $UPN."Work Extension"
"Email Address" = $UPN."Email Address"
"Supervisor Name" = $UPN."Supervisor Name"
"Job Code" = $UPN."Job Code"
"Job Title" = $UPN."Job Title"
"Location Code" = $UPN."Location Code"
"Location" = $UPN."Location"
"Org Level 1 Code" = $UPN."Org Level 1 Code"
"Org Level 1" = $UPN."Org Level 1"
"Org Level 2 Code" = $UPN."Org Level 2 Code"
"Org Level 2" = $UPN."Org Level 2"
"Org Level 3 Code" = $UPN."Org Level 3 Code"
"Org Level 3" = $UPN."Org Level 3"
"Org Level 4 Code" = $UPN."Org Level 4 Code"
"Org Level 4" = $UPN."Org Level 4"
"Salary Or Hourly Code" = $UPN."Salary Or Hourly Code"
"Union Code (Local)" = $UPN."Union Code (Local)"
"Date Of Birth" = $UPN."Date Of Birth"
"Home City" = $UPN."Home City"
"UID" = $UPN."UID"
"Network Username" = $UPN."Network Username"
"MB Flag" = $UPN."MB Flag"
})

}
Catch{
New-Object PSObject -Property ([ordered]@{
OBjectID = $null
"SKU" = $null
"Lic hrly" = $AGroup
"Lic Ex" = $Bgroup
"Both" = $BothG
"Enabled" = 'False'
"Employee Number" = $UPN."Employee Number"
"First Name" = $UPN."First Name"
"Preferred" = $UPN."Preferred"
"Last Name" = $UPN."Last Name"
"Work Phone" = $UPN."Work Phone"
"Work Extension" = $UPN."Work Extension"
"Email Address" = $UPN."Email Address"
"Supervisor Name" = $UPN."Supervisor Name"
"Job Code" = $UPN."Job Code"
"Job Title" = $UPN."Job Title"
"Location Code" = $UPN."Location Code"
"Location" = $UPN."Location"
"Org Level 1 Code" = $UPN."Org Level 1 Code"
"Org Level 1" = $UPN."Org Level 1"
"Org Level 2 Code" = $UPN."Org Level 2 Code"
"Org Level 2" = $UPN."Org Level 2"
"Org Level 3 Code" = $UPN."Org Level 3 Code"
"Org Level 3" = $UPN."Org Level 3"
"Org Level 4 Code" = $UPN."Org Level 4 Code"
"Org Level 4" = $UPN."Org Level 4"
"Salary Or Hourly Code" = $UPN."Salary Or Hourly Code"
"Union Code (Local)" = $UPN."Union Code (Local)"
"Date Of Birth" = $UPN."Date Of Birth"
"Home City" = $UPN."Home City"
"UID" = $UPN."UID"
"Network Username" = $UPN."Network Username"
"MB Flag" = $UPN."MB Flag"
})

}}








$res | Out-GridHtml