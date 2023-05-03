Function ADO-Flow {
  Begin {   $path = "C:\temp\SA_"
            If(!(test-path -PathType container $path))
            {
             New-Item -ItemType Directory -Path $path
            }
            Write-Host $("="*80) -ForegroundColor White
            Write-Host "ADO-Flow" -BackgroundColor Green -ForegroundColor Black -
          }   
  process{
   #region ADOPrep
          $ado = Get-ADObject -OutVariable ADOPrev -Filter {SamAccountName -eq $_}|select name,objectClass
            if ($_ -like "S-1-5-21-2118135359*" -and $ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SID'}}
            elseif($ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='NAD'}}
            ElseIf($ado.name -like "*svc*"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SVC'}} 
            Elseif($ado.name -like "LA_W*_LocalAdmin"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='LAG'}} 
            $ado | Add-Member -NotePropertyMembers @{Server=$system}

            $ADOPrev = $ADOPrev -split(",");$ADOPrev =  $ADOPrev[0] -replace('cn=','')
            $La_ = "LA_"+$system+"_localAdmin" 
            $adoName = $ado.name
            $adoSrv = $ado.server
            $adoObj = $ado.objectClass
                       
    #endregion ADOPrep

     Switch($ado.objectClass)#Action & Logging 
     {
        user { $VU = Validate-User
                If($vu.enabled -eq $true -and $VU.SA -eq 'HSA'){
                   # Add-ADGroupMember -Identity $La_ -Members $VU.SAacct 
                   Invoke-Command $system -scriptblock{Remove-LocalGroupMember -Group 'administrators' -Member $Using:VU.name}
                    "Directly ADDed HSA:`t$VU.name Removed from $La_" | Out-File -FilePath  C:\temp\sa_\20222410-LocalAdminDirect.csv -Append 
                 }
             }
        group {Write-Host "Checking Group $adoName"
               $res = $adoName | Group-Check
              }
        NAD   {Write-Host -ForegroundColor Red  "ADO SAYs $adoName Is NOT in AD";"ADO SAYs $adoName Is NOT in AD`t$system"| Out-File -FilePath  C:\temp\sa_\20222410-NAD.csv -Append}
        SVC   {Write-Host -ForegroundColor Yellow "IGNORE: $adoName <SB> add to localgroup $La_"; "IGNORE: $adoName <SB> add to localgroup $La_" | Out-File -FilePath  C:\temp\sa_\20222410-SVC.csv -Append }
        SID   {Write-Host -ForegroundColor RED  "REMOVE: $adoName"
               Invoke-Command $system -ScriptBlock{Remove-LocalGroupMember -Name 'Administrators' -Member $using:adoName }
               $SidOut = "REMOVED: $adoName`t$system"
               $SidOut | Out-File -FilePath  C:\temp\sa_\20222410-SID.csv -Append
              }
        LAG   {
                $adoName | Group-Check
                $adoName | Correct_LAGroup
              }
            
     }
}#eop
  End {write-Host "END ADO-flow`n`r" }
  }

Function Validate-User {
    Begin {
            Write-Host $("="*80) -ForegroundColor Magenta
            Write-Host "User Validation" -BackgroundColor Green -ForegroundColor Black -
          }   
    Process{
       $user = Get-ADUser -Identity $adoName |  select enabled,samaccountName,ObjectClass
           If($user.enabled -ne $true){$ado =[pscustomobject]@{Name=$adoName ; ObjectClass='NAD';Enabled='False';SA='Disabled';SRV=$system;SAacct=''}
           Write-Host -ForegroundColor Yellow "User Acct $adoName Disabled"; 
           } 
           ELSE{
        $Acct = $user.SamAccountName
        $SA_ = "SA_"+ $Acct
           if($Acct -like "SA_*"){Write-host -ForegroundColor DarkGray "IGNORE:IS SA_ $Acct"
            $ado =[pscustomobject]@{Name=$adoName ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA='SA';SRV=$system;SAacct=$adoName}
            continue}
            else {$SA_ = $SA_|Get-ADUser -ErrorAction SilentlyContinue  |select -ExpandProperty Name}
                If($SA_ -eq $null){Write-host -ForegroundColor Red "***NO SA_ account for $Acct`n`t`tWe should remove from:$system"
                $ado =[pscustomobject]@{Name=$adoName ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA='NSA';SRV=$system;SAacct=''}
                }
                ELSE{$La_ = "LA_"+$system+"_localAdmin"
                     Write-Host -ForegroundColor Cyan "Remove:HSA $Acct on $La_ >"
                     $ado =[pscustomobject]@{Name=$adoName ; ObjectClass=$user.objectClass;Enabled=$user.Enabled;SA='HSA';SRV=$system;SAacct=$SA_}
                     }
         }#end 1st Else
    }#eop 
    END{
     Write-Host "User Validation Action" -BackgroundColor Green -ForegroundColor Black -
     Write-Host $("="*80) -ForegroundColor Magenta
     #log it
     $ado |  Export-Csv -path C:\temp\sa_\20222410-user.csv  -NoTypeInformation -Append
     $ado
    }
 }

Function Group-Check{
       Param
    (
         [Parameter(ValueFromPipeline)]
         [string]$GrpName
     )
      $gc=@()
      $GC += Get-ADGroupMember $GrpName -Recursive |  select -ExpandProperty name | G-SA_Check
        $sac = $GC | ?{$_ -eq 'x'}
        $nsac = $GC | ?{$_ -eq 'N'}
        $Rem = $gc | ?{$_ -eq 'r'}
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
     
     $Newgc | ft | Out-String| Write-host
     $Newgc | Export-Csv -Path C:\Temp\SA_\20222410-groups.csv -Append -NoTypeInformation 

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
        if($Acct -like "SA_*"){$msg='X'}#SA already
        elseif($sa_ = $SA_|Get-ADUser -ErrorAction SilentlyContinue  |select -ExpandProperty Name ){
        # Has account just not using it.
          $msg="R" 
         }
        elseif($SA_ -eq $null){$msg='N'}
          $total += $msg            
      }#end Proc

  End{ $total 
       Write-Host $("="*80) -ForegroundColor  DarkMagenta}
  }
Function Get-LA{
                                $Administrators = Get-LocalGroup -SID 'S-1-5-32-544'
                                ## Get group members
                                $null = Add-Member -InputObject $Administrators -MemberType 'NoteProperty' -Force -Name 'Members' -Value (
                                    [string[]](
                                        $(
                                            [adsi](
                                                'WinNT://{0}/{1}' -f $env:COMPUTERNAME, $Administrators.'Name'
                                            )
                                        ).Invoke(
                                            'Members'
                                        ).ForEach{
                                          $([adsi]($_)).'path'.Split('/')[-1]
                                        }
                                    )
                                )
                                ## Output members
                             $Administrators.Members
                             }

Function Correct_LAGroup{
    if($adoname -like "LA_*"){
        $endGC = $adoName
        Get-ADGroupMember $adoname |?{$_.objectClass -eq "user"}|select -ExpandProperty Name | LAGroup-flow}
}
Function LAGroup-flow {
  Begin {  
            Write-Host $("="*80) -ForegroundColor Yellow
            Write-Host "LAGroup-flow" -BackgroundColor Green -ForegroundColor Black -
          }   

  process{
   #region LAGroup-flow ADO Prep
          $ado = Get-ADObject -OutVariable ADOPrev -Filter {SamAccountName -eq $_}|select name,objectClass
            if ($_ -like "S-1-5-21-2118135359*" -and $ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SID'}}
            elseif($ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='NAD'}}
            ElseIf($ado.name -like "*svc*"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SVC'}} 
            $ado | Add-Member -NotePropertyMembers @{Server=$system}

            $La_ = "LA_"+$system+"_localAdmin" 
            $adoName = $ado.name
            $adoSrv = $ado.server
            $adoObj = $ado.objectClass
    #endregion LAGroup-flow ADO Prep

     Switch($ado.objectClass)#Action & Logging 
     {
        user { $VU = Validate-User
                If($vu.enabled -eq $true -and $VU.SA -eq 'HSA'){
                    $laflowsrv =  $VU.SRV
                   Try{<#Add-ADGroupMember -Identity $La_ -Members $VU.SAacct#>}
                   catch{Write-Warning "Already a Member"}
                    $VU | Export-Csv -Path c:\temp\sa_\20222410-HSA-ADD-to-LAGroup.csv -NoTypeInformation -Append
                      Remove-ADGroupMember -Identity $La_ -Member $VU.name -Confirm:$false 
                    $VU | Export-Csv -Path c:\temp\sa_\20222410-HSA-Removed-From-LAGroup.csv -NoTypeInformation -Append
                    }
                Elseif($vu.enabled -eq $true -and $VU.SA -eq 'NSA'){
                   Remove-ADGroupMember -Identity $La_ -Member $VU.name 
                   $VU | Export-Csv -path c:\temp\sa_\20222410-NSA-Removed-From-LAGroup.csv -NoTypeInformation -Append
                   }
             }
        group {Write-Host "Checking Group $adoName"
                $adoName | Group-Check
              }
        NAD   {Write-Host -ForegroundColor Red  "ADO SAYs $adoName Is NOT in AD";"ADO SAYs $adoName Is NOT in AD`t$system"| Out-File -FilePath c:\temp\sa_\20222410-NOT-IN-AD.csv -Append}
        SVC   {Write-Host -ForegroundColor Yellow "IGNORE: $adoName Is already SA_"; "IGNORE`t$adoName`t$La_" | Out-File -FilePath  c:\temp\sa_\20222410-_SVC.csv -Append }
        SID   {Write-Host -ForegroundColor RED  "REMOVE: $adoName"
               Invoke-Command $system -ScriptBlock{Remove-LocalGroupMember -Name 'Administrators' -Member $using:adoName }
               $SidOut = "REMOVED: $adoName`t$system"
               $SidOut | Out-File -FilePath  c:\temp\sa_\20222410-SID.csv -Append 
              }
            
     }
}#eop
    END{
     Write-Host $("="*80) -ForegroundColor Yellow
     Write-Host "END: LAGroup-Flow" -BackgroundColor Green -ForegroundColor Black -
     $endGC  | Group-Check
     Write-Host $("="*80) -ForegroundColor Yellow
    }

}
