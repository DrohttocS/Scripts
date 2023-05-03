$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Invoke-Command -ComputerName twb-dc1 -Credential $AdminCred -ScriptBlock {
$DaysInactive = 90
$Time2remove = 120
$rtime = (Get-Date).Adddays(-($Time2remove))
$time = (Get-Date).Adddays(-($DaysInactive))
# Set Date Stamp Format
$TDate = Get-Date -Format g
$body=@()

$body += "PC's to be disabled`r`n"
$pcs = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and Enabled -eq $true  -and OperatingSystem -notlike '*Server*'} -Properties LastLogonTimeStamp | select-object Name,@{Name="Logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} 
Foreach ($pc in $pcs)
{
   $name = $pc.Name
   $ldate = $pc.Logon
   Set-ADComputer  -Identity $name -Description "Disabled  - $TDate Lastlogin - $ldate" -Enabled $false 
   Get-ADComputer $name |  Move-ADObject -TargetPath "OU=TWB Computers - Disabled,DC=bvb,DC=local"
   $body += "`r`n$name Was disabled - $TDate Lastlogin - $ldate"
}
    
$body += "`r`n`r`nTo be removed from AD.`r`n"
$RemPC = Get-ADComputer -Filter {LastLogonTimeStamp -lt $rtime -and Enabled -eq $false -and OperatingSystem -notlike '*Server*'} -Properties LastLogonTimeStamp | select-object Name,@{Name="Logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} 
Foreach ($delpc in $RemPC)
{
   $Rname= $delpc.Name
   $Rldate= $delpc.Logon
   Remove-ADComputer -Identity $Rname -confirm:$false
   $body += "`r`n$Rname Was Removed from AD - $TDate. It has been as disabled since: $Rldate"
 }
 
$encodedCredentials = "YnZiXHNob3JkMjEyNjpEcmFnMG5hc3Mh"
$headers = @{ Authorization = "Basic $encodedCredentials" }
$body = $body 

 #update a tickets comments
 $ticket = 4010
 $baseurl = "https://helpdesk.trailwest.bank"
 $api ="/api/comment?id=$ticket&Body=$body"
 $url = $baseurl+$api
 $HD = Invoke-WebRequest -Uri $url -Method post -Headers $headers 
 }