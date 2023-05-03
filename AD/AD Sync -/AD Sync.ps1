
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$syncSVR =  Get-ADUser -LDAPFilter "(description=*configured to synchronize to tenant*)"     -Properties description | % { $_.description.SubString(142, $_.description.IndexOf(" ", 142) -142)}
Invoke-Command -ComputerName $syncSVR  -Credential $AdminCred -ScriptBlock{
 Start-ADSyncSyncCycle -PolicyType Delta}
