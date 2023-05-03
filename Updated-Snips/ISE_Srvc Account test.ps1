$SRVC_ISE = $AdminCred = Get-StoredCredential -Target  "$env:USERNAME-ISE_srvc"
Get-WmiObject Win32_ComputerSystem -ComputerName 'FZUCNNDSVPDC01', 'SHDCNNDSVPDC01' -Credential $SRVC_ISE