$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$gpos = Import-Csv -Path "C:\Users\nmc77pw\Documents\Temp\GPO-copies.txt"
Enter-PSSession -ComputerName "FRANGPINFDC01" -Credential $AdminCred

Invoke-Command -ComputerName "FRANGPINFDC01" -Credential $AdminCred -ScriptBlock{
Copy-GPO -SourceName 'NIDECDS_WiFi' -TargetName 'NIDECDS_WiFi_LS'
}



Exit-PSSession