$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$dc =  $env:LOGONSERVER.Replace('\\','')
$DaysInactive = 3
$Time2remove = 12
$rtime = (Get-Date).AddMonths(-($Time2remove))
$time = (Get-Date).AddMonths(-($DaysInactive))

# Disable Phase
$disabledLOC = "OU=Aged-out,OU=Disabled Computers,DC=NISH,DC=ORG"
$pcs = Get-ADComputer -Server $dc -Filter {LastLogonTimeStamp -lt $time -and Enabled -eq $true  -and OperatingSystem -notlike '*Server*'} -Properties LastLogonTimeStamp,CanonicalName |?{$_.CanonicalName -notlike '*SERVER*'} |select-object Name,@{Name="Logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}},CanonicalName

  Foreach ($pc in $pcs){
   $name = $pc.Name
   $ldate = $pc.Logon
      $CurrentDate = get-date -Format d
   Invoke-Command -ComputerName $dc -Credential $AdminCred -ScriptBlock {
       Set-ADComputer  -Identity $using:name -Description "Disabled  - $using:CurrentDate Lastlogin - $using:ldate" -Enabled $false | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru 
       Get-ADComputer -Identity $using:name |  Move-ADObject -TargetPath $using:disabledLOC
       }

}

#Removal Phase
$RemPC2 = Get-ADComputer -Server 'saeqdc01' -Filter {LastLogonTimeStamp -lt $rtime -and Enabled -eq $true  -and OperatingSystem -notlike '*Server*'} -Properties LastLogonTimeStamp,CanonicalName |?{$_.CanonicalName -notlike '*SERVER*'} |select-object Name,@{Name="Logon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}},CanonicalName
Foreach ($delpc in $RemPC2){
   $Rname = $delpc.Name
   $Rldate= $delpc.Logon
   $CurrentDate = get-date -Format d
   Invoke-Command -ComputerName 'saeqdc01' -Credential $AdminCred -ScriptBlock {Get-ADComputer -Identity $using:rname | Set-ADObject -ProtectedFromAccidentalDeletion:$false -PassThru | Remove-ADObject -Recursive -Confirm:$false}
   
   $body += "`r`n$Rname Was Removed from AD - $TDate. It has been as inactive since: $Rldate"
 }




