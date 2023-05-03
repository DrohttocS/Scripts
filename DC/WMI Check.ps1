$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
Function ListDcs{Get-ADDomainController -Filter * | select Name -ExpandProperty name }
$dcs =  ListDcs

Invoke-Command -ComputerName $dcs -Credential $AdminCred -ScriptBlock {Get-CimInstance -ClassName Win32_ComputerSystem } | Sort-object name