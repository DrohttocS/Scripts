## Install-module PSExcel
$path = "C:\Users\shord2126\TrailWest Bank\IT Team - Documents\DefendEdge\DefendEdge HR File.xlsx"

$TCU = Import-XLSX -Path $path
$TDate = Get-Date -Format d
$Defend = @()
foreach($user in $TCU){
$email = $user.Email
$sam = Get-ADUser -Filter {EmailAddress -eq $email} -Properties DistinguishedName,Name,SamAccountName | select samaccountname
$sam = $sam.samaccountname
$user.sAMAccount = $sam
$Defend += $user

}
$Defend |  Export-XLSX -Path $path -WorksheetName "AD - $TDate"
$Defend | ft -AutoSize -Wrap
