Function MidADO-Flow {
  process{ 
      
      $ado = Get-ADObject -OutVariable ADOP -Filter {SamAccountName -eq $_}|select name,objectClass
        if ($_ -like "S-1-5-21-2118135359*" -and $ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SID'}}
        elseif($ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='NAD'}}
        ElseIf($ado.name -like "*svc*"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SVC'}} 
        $La_ = "LA_"+$system+"_localAdmin" 
     Switch($ado.objectClass)
        {
        user
            {$a = Z-SA_Check $ado.name; $a | Tee-Object -FilePath C:\temp\sa_\user.txt -Append}
        group
            {$ado = $ado.name
            Write-host "`t$ado is a group. Source: $_" |  Tee-Object -FilePath C:\temp\sa_\groups.txt -Append
             Get-ADGroupMember -Identity $ado -OutVariable Prev| select -ExpandProperty name | MidADO-Flow
             }
        NAD
            {$ado=$ado.name ;Write-Host -ForegroundColor Red  "MidADO SAYs $ado Is NOT in AD"  | Tee-Object -FilePath C:\temp\sa_\NAD.txt -Append}
        SVC
            {$ado=$ado.name | Tee-Object -FilePath C:\temp\sa_\SVC.txt -Append;Write-Host -ForegroundColor Gray  "IGNORE: $ado <SB> add to localgroup $La_" }
        SID
            {$ado=$ado.name ;Write-Host -ForegroundColor RED  "REMOVE: $ado" | Tee-Object -FilePath C:\temp\sa_\SID.txt -Append}
          }
}
}
Function ADO-Flow {
  Begin {
            Write-Host "=======================================================" -ForegroundColor White
            Write-Host "ADO-Flow" -BackgroundColor Green -ForegroundColor Black -
          }   
  process{ 
      
        $ado = Get-ADObject -OutVariable ADOP -Filter {SamAccountName -eq $_}|select name,objectClass
        if ($_ -like "S-1-5-21-2118135359*" -and $ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SID'}}
        elseif($ado -eq $null){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='NAD'}}
        ElseIf($ado.name -like "*svc*"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SVC'}} 
         $ADOP = $ADOP -split(",");$ADOP =  $ADOP[0] -replace('cn=','')
         $La_ = "LA_"+$system+"_localAdmin" 
     Switch($ado.objectClass)
        {
        user
            {$a = Z-SA_Check $ado.name; $a | Tee-Object -FilePath C:\temp\sa_\user.txt -Append}
        group
            {$ado = $ado.name
            Write-host "`t$ado is a group. Source: " |  Tee-Object -FilePath C:\temp\sa_\groups.txt -Append
             Get-ADGroupMember -Identity $ado -OutVariable Prev | select -ExpandProperty name | MidADO-Flow
             }
        NAD
            {$ado=$ado.name ;Write-Host -ForegroundColor Red  "ADO SAYs $ado Is NOT in AD"  | Tee-Object -FilePath C:\temp\sa_\NAD.txt -Append}
        SVC
            {$ado=$ado.name | Tee-Object -FilePath C:\temp\sa_\SVC.txt -Append  ;Write-Host -ForegroundColor Yellow "IGNORE: $ado <SB> add to localgroup $La_" }
        SID
            {$ado=$ado.name ;Write-Host -ForegroundColor RED  "REMOVE: $ado" | Tee-Object -FilePath C:\temp\sa_\SID.txt -Append}
          }
}
  End {
         $prev = $prev -split(",");$prev =  $prev[0] -replace('cn=','')
         $ADOP = $ADOP -split(",");$ADOP =  $ADOP[0] -replace('cn=','')  
   #       $ADOP += $ADOP | select -Last 1
        write-Host "END zADO:$ADOP"
     }

}
Function Z-SA_Check{
       [CmdletBinding()]
   Param
    (
         [Parameter(ValueFromPipeline)]       
         [string] $Acct
    )
 Begin {Write-Host "=======================================================" -ForegroundColor  DarkMagenta}  



 
  Process{
         $SA_ = "SA_" + $Acct   
        if($Acct -like "SA_*"){Write-host -ForegroundColor Yellow "IGNORE: $Acct"}
        elseif($sa_ = $SA_|Get-ADUser -ErrorAction SilentlyContinue  |select -ExpandProperty Name ) {
            $La_ = "LA_"+$system+"_localAdmin"
            Write-Host -ForegroundColor Cyan "ADD: $Acct has an SA_ account: $SA_ to $La_ `n<insert SB here.>"
            
         }
        elseif($SA_ -eq $null){Write-host -ForegroundColor Red "***NO SA_ account for $Acct`n`t`tWe should remove from:$system"}
                   
      }#end Proc
  
  End{ Write-Host "=======================================================" -ForegroundColor  DarkMagenta}
  }
   
 
$systems = "WSRV1027"

$srv=@()
 $srv= foreach($system in $systems){
 $a =  Invoke-Command $system -ScriptBlock{
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
                Write-host "Getting Current Local Admins from $using:system"
    Get-LA
    }#end of script bloack
    foreach($item in $a){[pscustomobject]@{Server=$systems ; Account=$item}}
   #cleanup results
  $a.Count
 
   $b = $a|?{$_ -ne 'GatesW' -and $_ -notlike 'Domain admins' -and $_ -ne "Corp_Solutions" -and $_ -ne "serveradmin" -and $_ -ne 'LA_Servers_All_LocalAdmin'}
   $b.count
   $b
   $b|ADO-Flow

   
   }
   $srv

   $b
   $a