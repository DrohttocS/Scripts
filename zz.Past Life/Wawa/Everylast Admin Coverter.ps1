

$table =  Import-Csv -Path "C:\Temp\EveryLastAdmin_Nov.csv"


Function Get-C2-Type{
       Param
    (
         [Parameter(ValueFromPipeline)]
         [string]$Name
     )

Begin {
           $LAGDom = $null
           $LAGSam = $null


       }

Process{   $Name = $line.LocalAdminGroup
           $LAGDom =  $Name.Split("\")[0]
           $LAGSam =  $Name.Split("\")[1]
           Get-ADObject -Filter {SamAccountName -eq $LAGSam}|select name,objectClass     
       }
}
Function Get-C3-Type{
       Param
    (
         [Parameter(ValueFromPipeline)]
         [string]$Name
     )

Begin {
           $LAGDom = $null
           $LAGSam = $null
       }

Process{   $Name = $line.user
           Get-ADObject -Filter {SamAccountName -eq $Name}|select name,objectClass     
       }
}
Function DOMorLocal{
       Param
    (
         [Parameter(ValueFromPipeline)]
         [string]$Name
     )

Begin {
           $LAGDom = $null
           $LAGSam = $null
}
Process{   $Name = $line.LocalAdminGroup
           $LAGDom =  $Name.Split("\")[0]
           $LAGSam =  $Name.Split("\")[1]
          if($line.server -eq $LAGDom ){'Local'}Else{$LAGDom} 
}
}
Function Validate-User {
   Param
    (
         [Parameter(ValueFromPipeline)]       
         [string] $Acct
    )

    Begin{$ado=$null}
    Process{
    
         $user = Get-ADUser -Identity $Acct -ErrorAction SilentlyContinue |  select enabled,samaccountName,ObjectClass
         $SA_ = "SA_"+ $Acct
     Try{$SACheck = Get-ADUser $SA_ -ErrorAction SilentlyContinue | select -ExpandProperty Name}Catch{$SACheck = $null}

         If($Acct -like "sa_*"){$ado =[pscustomobject]@{Name=$Acct ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA_Level='SA';AccountType = 'SA';Exception = '';SAacct=$Acct}}
         Elseif($Acct -like "*SVC*"){$ado =[pscustomobject]@{Name=$Acct ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA_Level='SA';AccountType = 'SVC';Exception = '';SAacct=$Acct}}
         Elseif($user.enabled -ne $true){$ado =[pscustomobject]@{Name=$Acct ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA_Level='N/A';AccountType = 'N/A';Exception = 'Disabled';SAacct=$null}}
         Elseif($SACheck -eq $null){$ado =[pscustomobject]@{Name=$Acct ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA_Level='NSA';AccountType = 'Regular';Exception = $null;SAacct=$null}}
         Elseif($SACheck -ne $null){$ado =[pscustomobject]@{Name=$Acct ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA_Level='HSA';AccountType = 'HAS SA';Exception = $null;SAacct=$SA_}}
     $ado
    }#eop
    END{}

}
Function Group-Check{
       Param
    (
         [Parameter(ValueFromPipeline)]
         [string]$GrpName
     )
      $gc=@()
      $GC += Get-ADGroupMember $GrpName -Recursive |  select -ExpandProperty name | G-SA_Check
        $sac = $GC | ?{$_ -eq 'SA'}
        $nsac = $GC | ?{$_ -eq 'NSA'}
        $Rem = $gc | ?{$_ -eq 'HSA'}
             if(($sac.count -ge 1 ) -and ($nsac.count -eq 0 -and $Rem.count -eq 0)){$rf='SA'}
             elseif(($sac.count -ge 1 -or $Rem.count -ge 1 ) -and ($nsac.count -eq 0 )){$rf='Update'}
             elseif(($sac.count -eq 0 -and $Rem.count -eq 0) -and($nsac.count -ge 1)){$rf='Non-SA'}
             elseif(($sac.count -ge 1 -or $Rem.count -ge 1) -and ($nsac.count -ge 1)){$rf='Mixed'}
             Else{$rf='Unknown'}
        $Newgc = New-Object PSObject -Property ([ordered]@{
            Group = $GrpName
            Count= $gc.count
            SAcount = $sac.count
            NSAcount= $nsac.count
            Botched = $Rem.count
            RemediationFlag= $RF
            Server= $system
             })
     
     $Newgc.RemediationFlag

 }
 Function G-SA_Check{
       [CmdletBinding()]
   Param
    (
         [Parameter(ValueFromPipeline)]       
         [string] $Acct
    )

 Begin {Write-Host $("="*80) -ForegroundColor  DarkMagenta
        $total=@()
 }  
 Process{
         $SA_ = "SA_" + $Acct   
        if($Acct -like "SA_*"){$msg='SA'}#SA already
        elseif($sa_ = $SA_|Get-ADUser -ErrorAction SilentlyContinue  |select -ExpandProperty Name ){
        # Has account just not using it.
          $msg="HSA" 
         }
        elseif($SA_ -eq $null){$msg='NSA'}
        elseif($SA_ -contains "SVC"){$msg='SVC'}
          $total += $msg            
      }#end Proc

  End{ $total 
       Write-Host $("="*80) -ForegroundColor  DarkMagenta}
  }



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


$t2 | Export-Csv -Path $env:USERPROFILE\desktop\EveryLastAdmin_DEC.csv -NoTypeInformation