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