#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Hmail"

$IP = '172.16.10.36'
$mhost = 'AMRNMCVPMG01.nmca.org'

Invoke-Command -ComputerName $IP -Credential $AdminCred -ScriptBlock{
$path = 'C:\Program Files (x86)\hMailServer\Logs\'
$currentlog = gci $path | sort LastWriteTime | select -last 1
$log = "$path$currentlog"
Get-Content $log -wait
}

Enter-PSSession -ComputerName $mhost -Credential $AdminCred