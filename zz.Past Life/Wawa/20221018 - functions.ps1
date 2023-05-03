Function MidADO-Flow {
  process{ 
      $ado = Get-ADObject -Filter {SamAccountName -eq $_}|select name,objectClass
        if ($ado -eq $null) {$ado =[pscustomobject]@{Name=$_ ; ObjectClass='NAD'}}
        ElseIf($ado.name -like "*svc*"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SVC Account'}} 
         
     Switch($ado.objectClass)
        {
        user
            {$a = Z-SA_Check $ado.name; $a | Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\user.txt -Append}
        group
            {$ado = $ado.name
            Write-host "`t$ado is a group." |  Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\groups.txt -Append
             Get-ADGroupMember -Identity $ado -OutVariable Prev| select -ExpandProperty name | MidADO-Flow
            }
        NAD
            {$ado=$ado.name ;Write-Host -ForegroundColor Red  "ADO SAYs $ado Is NOT in AD"  | Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\NAD.txt -Append}
        SVC
            {$ado=$ado.name ;Write-Host -ForegroundColor Yellow  "IGNORE: $ado" | Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\SVC.txt -Append}
          }
}
}

Function zADO-Flow {
  Begin {
            Write-Host "=======================================================" -ForegroundColor White
            Write-Host $CallType  -BackgroundColor Yellow -ForegroundColor Blue
            Write-Host "zADO" -BackgroundColor Green -ForegroundColor Black -
          }   
  process{ 
      $ado = Get-ADObject -OutVariable ADOP -Filter {SamAccountName -eq $_}|select name,objectClass
        if ($ado -eq $null) {$ado =[pscustomobject]@{Name=$_ ; ObjectClass='NAD'}}
        ElseIf($ado.name -like "*svc*"){$ado =[pscustomobject]@{Name=$_ ; ObjectClass='SVC Account'}} 
         
     Switch($ado.objectClass)
        {
        user
            {$a = Z-SA_Check $ado.name; $a | Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\user.txt -Append}
        group
            {$ado = $ado.name
            Write-host "`t$ado is a group." |  Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\groups.txt -Append
             Get-ADGroupMember -Identity $ado -OutVariable Prev| select -ExpandProperty name | MidADO-Flow
             }
        NAD
            {$ado=$ado.name ;Write-Host -ForegroundColor Red  "ADO SAYs $ado Is NOT in AD"  | Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\NAD.txt -Append}
        SVC
            {$ado=$ado.name ;Write-Host -ForegroundColor Yellow  "IGNORE: $ado" | Tee-Object -FilePath C:\Users\wcw101934\Desktop\SA_\SVC.txt -Append}
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
 Begin {#Write-Host "=======================================================" -ForegroundColor  DarkMagenta
    Write-Host $CallType -BackgroundColor Yellow -ForegroundColor Blue
#    Write-Host 'Z-SA_Check' -BackgroundColor Green -ForegroundColor Black -
    
}  



 
  Process{   
        if($Acct -like "SA_*"){Write-host -ForegroundColor Yellow "IGNORE: $Acct";continue}
            else{
                 $SA_ = ("SA_" + $Acct | Get-ADUser -ErrorAction SilentlyContinue  | select -ExpandProperty Name )}
                 if([string]::IsNullOrWhiteSpace($SA_)){Write-host -ForegroundColor Red "$Acct NO SA_ account for $Acct`n`t`tWe should remove from: "
                   }
                 Else{Write-Host -ForegroundColor Cyan "IGNORE: $Acct has an SA_ account: $SA_"
                       #check if in group already
                     }
      }#end Proc
  
  End{   $prev = $prev -split(",");$prev =  $prev[0] -replace('cn=','') 
         Write-Host "Feed From: $acct"}
  }
  