$DMZ = "AMRNDSVPAP65","AMRNDSVPWE09","AMRNDSVPWE02","amrndsvpap01","amrndsvdap01","AMRNDSVPAP15","AMRNDSVPWE04","AMRNMCVPMG01","AMRNMCVDWE02","AMRNMCVPWE02","AMRNDSVPWE06","AMRNDSVDAP29","AMRNMCVPLD03","AMRNDSVPAP28","AMRNDSVPAP64","AMRNDSVPAP31","AMRNDSVPWE03"
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Foreach($srv in $DMZ){

Invoke-Command -ComputerName $selection -Credential $AdminCred -ScriptBlock{
           $localusers = Get-LocalUser admin | ?{$_.enabled -eq $true}| Set-LocalUser -PasswordNeverExpires 1  

       

}
