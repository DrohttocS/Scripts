$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$test = "AMRNDSVPAD03","AMRNDSVPJB01","AMRNDSVPNP02"
$session = New-PSSession -Credential $AdminCred  -ComputerName $test

cls
Invoke-Command -Session $session -scriptblock  {
hostname
Gpupdate
$pol = auditpol /get /category:"Account Management"
$pol |ft -AutoSize -Wrap

}


Get-PSSession | Remove-PSSession