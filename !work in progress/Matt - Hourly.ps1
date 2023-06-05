 

#TimeStamp for start of script runtime
$StartTime = Get-Date

 

#Create Excel COM object
$ExcelObject = New-Object -ComObject Excel.Application
$ExcelObject.Visible = $true
$ExcelObject.DisplayAlerts = $false
Timeout 2

 

#Opens Workbook
$ExcelWorkBook = $ExcelObject.Workbooks.Open("https://gsfglobal.sharepoint.com/sites/InformationSecurity587/Shared%20Documents/Active%20Directory%20Cleanup/User_Security_Provisioning_with derived User Name.xlsx")
$WorkSheet = $ExcelWorkBook.Worksheets("Page1")
Timeout 2

 

#Checks if C:\Temp folder exists and creates it if it doesn't
$FolderName = "C:\Temp"
if (Test-Path $FolderName) {

    Write-Host "Folder Exists"
}
else
{

    New-Item $FolderName -ItemType Directory
    Write-Host "Folder Created successfully"
}
$WorkSheet.SaveAs("C:\Temp\UKG.CSV", 6)

 

#Closes Workbook and Removes Excel Com Object
$ExcelWorkBook.Close()
$ExcelObject.Quit()
While([System.Runtime.Interopservices.Marshal]::ReleaseComObject($ExcelWorkBook) -ge 0){}
while([System.Runtime.Interopservices.Marshal]::ReleaseComObject($ExcelObject) -ge 0){}
taskkill /im excel.exe /F

 

#Load UKG Data Source
$UKG = Import-Csv -Path "C:\Temp\UKG.CSV"

 

#Clean Up Temp file
Remove-Item C:\Temp\UKG.CSV

 

#Filter on Hourly and non Kanpak
$UKGGSFHourly = $UKG | Where {$_.'Salary Or Hourly Code' -ne 'S' -and $_.'MB Flag' -ne 'Y' -and $_.'Email Address' -notmatch 'kanpak.us' -and $_.'Email Address' -notmatch 'ourkanpak.com'}
$UKGGSFSalary = $UKG | Where {$_.'Salary Or Hourly Code' -ne 'H' -and $_.'MB Flag' -ne 'Y' -and $_.'Email Address' -notmatch 'kanpak.us' -and $_.'Email Address' -notmatch 'ourkanpak.com'}

 

#Authenticate to MSGraph
Connect-MgGraph -ClientID f324340f-1589-43ea-b7c0-9e7552bca398 -TenantId c6cb47f3-d8a4-47d0-8139-b43165edd882
Timeout 2
select-mgprofile -name beta
Timeout 2
#Get Licensed_Hourly_Users Azure AD Group Members and build array with UPN and EmpID
$AllUsers = Get-MgUser -All -Property DisplayName,UserPrincipalName,SigninActivity,EmployeeId,createdDateTime,AssignedLicenses
$Licensed_Hourly_Users = Get-MGGroupMember -All -GroupId "b7b6a7cf-044a-49f5-8cf4-e982523b6f0c"
$Licensed_E3_Hourly_Exceptions = Get-MGGroupMember -All -GroupId "37f9b668-870c-4eb1-b634-2bf29092f63e"
$Licensed_E3_Hourly_ExceptionsIds = $Licensed_E3_Hourly_Exceptions | ForEach-Object {
    [pscustomobject]@{
        EmployeeId                   = $_.additionalProperties['employeeId']
    }
}
$Licensed_Hourly_Users | ForEach-Object {
    $UPN = $_.additionalProperties.userPrincipalName
    $EmployeeId = $_.additionalProperties.employeeId
    [pscustomobject]@{
        DisplayName                  = $_.additionalProperties.displayName
        EmployeeId                   = $_.additionalProperties.employeeId
        Created                      = $_.additionalProperties.createdDateTime
        UserPrincipalName            = $_.additionalProperties.userPrincipalName
        accountEnabled               = $_.additionalProperties.accountEnabled
        LastAzureSignIn              = ($AllUsers | where { $_.userprincipalname -match $upn }).signinactivity.lastsignindatetime
        ExistsInHourlyUKG            = if ($UKGGSFHourly."Employee Number" -eq $_.additionalProperties.employeeId) {'True'} else {'False'}
        E3Exeption                   = if ($Licensed_E3_Hourly_Exceptions.additionalProperties.employeeId -eq $_.additionalProperties.employeeId) {'True'} else {'False'}
        E3ExeptionUPN                = ($AllUsers | where {$_.employeeId -match $EmployeeId -and $_.UserPrincipalName -ne $UPN}).UserPrincipalName
        E3ExeptionCreated            = ($AllUsers | where {$_.employeeId -match $EmployeeId -and $_.UserPrincipalName -ne $UPN}).createdDateTime
        E3ExeptionLastSignIn         = ($AllUsers | where {$_.employeeId -match $EmployeeId -and $_.UserPrincipalName -ne $UPN}).signinactivity.lastsignindatetime
        ExistsInSalaryUKG            = if ($UKGGSFSalary."Employee Number" -eq $_.additionalProperties.employeeId) {'True'} else {'False'}
    }
} | Out-HTMLView -Title 'Licensed_Hourly_Users_Report'

 

#Disconnect from Microsoft Graph
Disconnect-MgGraph

 

#TimeStamp for end of script runtime
$StopTime = Get-Date

 

#Get Script Total Runtime in Minutes
Write-Host (($StopTime)-($StartTime)).TotalMinutes 'Total Minutes Runtime'