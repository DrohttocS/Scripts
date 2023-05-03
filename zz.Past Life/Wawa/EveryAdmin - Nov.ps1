$table =  Import-Csv -Path "C:\Temp\EveryLastAdmin_Nov.csv"
$table.Count
$table2 = $table 
$TC = $table2.Count
$counter = 0
$t2 = foreach($line in $table2){
$counter++
 Write-Progress -Activity "Processing Line $counter out of $TC"  -PercentComplete (($counter / $TC) * 100)
  
 #logic 
    $AG = $line | Get-C2-Type | select -ExpandProperty objectClass
    $AcctC2 = $line.LocalAdminGroup.Split('\')[1]
     If($AG -eq "User"){$AC = $AcctC2 | Validate-User}
     ElseIF($AG -eq 'Group'){ $gc = $AcctC2 | Group-Check}
    $Acct = if([string]::IsNullOrWhiteSpace($line.user)){$line.LocalAdminGroup.Split('\')[1]}else{$line.user} 
    $NestedGroup =  if([string]::IsNullOrWhiteSpace($line.user)){$null}else{$line | Get-C3-Type | select -ExpandProperty Objectclass} 
        If($NestedGroup -eq 'User'){$AC = $Acct | Validate-User}
        ElseIf($NestedGroup -eq 'Group'){$gc = $Acct | Group-Check}

    New-Object PSObject -Property ([ordered]@{
        Server = $line.server
        LocalAdminGroup = $line.LocalAdminGroup
        User = $line.user
        Scope =  if($line.server -like "wsrv*" -and ($line.server -notlike "*aws*" -and $line.server -notlike "*AZ*")){'IN'}Else{'Out'}
        'Dom or Local' = DOMorLocal
        AG =  If($AG -eq 'Group'){'GA'}Else{'DA'}
        NSA = If($AC.SA_Level -eq 'NSA'){'X'}Else{$null}
        HSA = If($AC.SA_Level -eq 'HSA'){'X'}Else{$null}
        SA =  If($AC.SA_Level -eq 'SA'){'X'}Else{$null}
        SVC = If($AC.SA_Level -eq 'SVC'){'X'}Else{$null}
        Disabled = If($AC.Enabled -eq $False){'X'}Else{$null}
        nestedGroup = if($NestedGroup -eq 'Group'){'Nested'}else{$null}
        GroupRating = $GC
        Validated = ''
        Exception = ''
        }) #Enof of OBJ
}

#$table2 | ft 
#$t2 | Out-GridView
#$table | Out-GridView

#more cool struff
$t2 | Export-Csv -Path $env:USERPROFILE\desktop\EveryLastAdmin_DEC.csv -NoTypeInformation