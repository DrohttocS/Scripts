$dc = "CORUSNDSVPDC01","MARCANDSVPDC01","DEFRAPINFDC01","FRANGPINFDC02","INBNGPINFDC01","GLEUSNDSVPDC01","INPUSNDSVPDC01","PRNUSNDSVPDC02","AMRNDSVPDC06","CANUSNDSVPDC01","AMRNDSVPDC02","AMRNDSVPDC05","MENUSNDSVPDC01","AKRUSNDSVPDC01","MIDUSNDSVPDC01","DESALPINFDC01"

$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

$session = New-PSSession -Credential $AdminCred  -ComputerName $dc
$res = Invoke-Command -Session $session -ScriptBlock{SystemInfo | find "Boot Time:"}
$Res

Remove-PSSession $session

(Get-Date) - [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime)