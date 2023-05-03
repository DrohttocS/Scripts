
#local admin prj - redo.ps1
Function User_check{
    if([string]::IsNullOrWhiteSpace($line.user)){'Blank'}Else{$line.user |SA_Check}
    }
Function SA_Check{
   Process{
   Try{if($_ -like "SA_*"){$_ ; $true}else{$_; [bool]("SA_" + $_ | Get-ADUser -ErrorAction SilentlyContinue)}}catch{Write-Output $_.exception.message}
           }
}
Function ADO_Type{
     Process{ 
      $ado = Get-ADObject -Filter {SamAccountName -eq $_}|select objectClass -ExpandProperty objectClass
         if ($ado.count -gt 0) {$ado} else {'Not in AD'}
         }

}
Function AG_CLeaner_Domain{
$u = if([string]::IsNullOrWhiteSpace($line.user)){'Blank'}Else{$line.user}
$b = $line.admin.split("\\")[0]
$c = if([string]::IsNullOrWhiteSpace($line.admin.split("\\")[-1])){'Blank'}Else{$line.admin.split("\\")[-1]}
$dt= if($b -eq 'CORPORATE' -or $b -eq 'Stores'){'CORP'}else{'Local'}
$d = $C | ADO_Type
$e = if ($d -eq 'user'){if([string]::IsNullOrWhiteSpace($c)){'Blank'}Else{$C|SA_Check}}
$f = if($u -ne 'Blank'){$u | SA_Check}else{$d}
$hash = @{     
                    User = $u
                    'Has an SA User account' = $f
                    Admin = $line.admin
                    Server = $line.server
                    Domain  = $b
					'AD Obj Type' = $d
					'User from Group' = $c
                    'Has an SA from Group' = $e
                    DomType =  $dt
                    				}
				$obj = new-object psobject -Property $hash
				$obj
			}

#free standing

$parm = "WSRV5270","wcw101934"

Function Create-LArdp{
 Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $Server,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $SamAccountName
    )

    Write-Host "$Server   $SamAccountName"
    Invoke-Command $Server -scriptblock { 
        Get-LocalGroupMember "Remote Desktop Users" 
        #Remove-LocalGroupMember -Group "Remote Desktop Users" -Member $using:SamAccountName
        #Add-LocalGroupMember -Group "Remote Desktop Users" -Member $using:SamAccountName
        sleep -Seconds 3
        Get-LocalGroupMember "Remote Desktop Users" 
    }

    }


    If($Grpline.Count -ge 1){
    #Group access; Is the user in the LA group.
 Write-host "Checking Group Access"
 foreach($GA in $Grpline){
     $u = $GA.user
     $g = $GA.usergroup
     $LaG = 'LA_' + $GA.server + '_LocalAdmin'
     $GAu = [bool]($LaG |Get-ADGroupMember| select -ExpandProperty name)
     if ($GAu -eq $true){write-host "$u - $LaG"}else{Write-Host "$u Needs to be added to $LaG"}
 }
 }else{
    
  
#Direct access; Is the user in the LA group.
 Write-host "Checking Direct Access"
 foreach($DA in $DirAccess){
     $u = $da.user
     $g = $da.usergroup
     $LaG = 'LA_' + $DA.server + '_LocalAdmin'
     $dau = [bool]($LaG |Get-ADGroupMember| select -ExpandProperty name)
     if ($dau -eq $true){write-host "$u - $LaG"}else{
     Write-Host "$u Needs to be added to $LaG"}
 }

 Function Z-access-type {
  Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $Server,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $SamAccountName
    )


 }