#######
#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
# Store your credentials - Enter your username and the app password
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Enter-PSSession -ComputerName LLO-EVITA-0418 -Credential $AdminCred
$nactpc = "ABB-OPER01-0120","BON-NACT01-1218","BON-NACT03-0719","COR-NACTX-0819","DESKTOP-6GT3D2L","EVR-CSR1-1219","FRN-BCLAR-0319","frn-nact01-0317","HAM-CSR1-0120","HAM-CSR2-1019","HAM-CSR3-0319X","HAM-LOBBY2-0520","kal-kwoll-0416","KAL-NACT1-1219","Kal-nact3-1118","LLO-EVITA-0418","LLO-NewAccts03","llo-oper01-1119","LLO-Vdersam","MBW-NACT01-0120","MBW-NACT02-0120","MBW-TLR01-0116","MBW-TLR02-0116","MDB-NACT02-0120","MDB-NACT03-0420","MMS-DSAND-0819","SS1-OFFICE-0418","STR-NACT01-0120","SUP-NACT01-0919","LLO-NEWACCT","LLO-Newaccts02"

# get NewAccounts process
$newaccounts = Get-Process firefox -ErrorAction SilentlyContinue
if ($newaccounts) {
  # try gracefully first
  $firefox.CloseMainWindow()
  # kill after five seconds
  Sleep 5
  if (!$firefox.HasExited) {
    $newaccounts | Stop-Process -Force
  }
}
Remove-Variable firefox


$nactpc = "BON-NACT03-0719","COR-NACTX-0819","HAM-CSR2-1019","EVR-CSR1-1219","FRN-BCLAR-0319","FRN-NACT01-0317","HAM-CSR1-0120","HAM-CSR3-0319X","HAM-LOBBY2-0520","kal-kwoll-0416","KAL-NACT1-1219","KAL-NACT3-1118","LLO-EVITA-0418","LLO-NEWACCT","LLO-NewAccts03","LLO-OPER01-1119","LLO-VDERSAM","LLO-NEWACCTS02","MDB-NACT02-0120","MBW-NACT01-0120","MBW-NACT02-0120","MBW-TLR02-0116","MDB-NA01","MDB-NA02","MDB-PROOF","MMS-DSAND-0819","SS1-OFFICE-0418","STR-NACT01-0120","SUP-NACT01-0919","SUP-DSIMONS-091"


$isup=@()
$isDown=@()
$nactpc | ForEach {

        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
         
            write-Host "$_ is alive and Pinging " -ForegroundColor Green 
            $isup += $_
         
                    } else 
                     
                    { Write-Warning "$_ Not online or accessable"
             $isDown += $_
                    }     
         
} 

$new = New-PSSession -Credential $AdminCred -ComputerName $isup  -ErrorAction SilentlyContinue

Invoke-Command -Session $new {
#Check if Access is running 
$newaccounts = Get-Process MSAccess -ErrorAction SilentlyContinue
if ($newaccounts) {
  # try gracefully first
  $newaccounts.CloseMainWindow()
  # kill after five seconds
  Sleep 5
  if (!$newaccounts.HasExited) {
    $newaccounts | Stop-Process -Force
  }
}

#check for folder
$rootPath = "C:\Cardinal"
$path = "C:\Cardinal\SCS_Support"
$dpath = ((Get-Date).ToString('yyyy-MM-dd'))
$pcname = Hostname
$date = Get-Date
$dpath = $path + "\$dpath"
If(!(test-path $path)){New-Item -ItemType Directory -Force -Path $path}
New-Item -ItemType Directory -Path $dpath
Move-Item -Path "C:\Cardinal\Accounts" -Destination $dpath
Move-Item -Path "C:\Cardinal\bsi" -Destination $dpath
Move-Item -Path "C:\Cardinal\shared" -Destination $dpath
Copy-item -Recurse -Path "\\twb-files\Data\General\OPERATIONS\Apps & Drivers\New Accounts Form Update\Accounts" -Destination $rootPath
Copy-item -Recurse -Path "\\twb-files\Data\General\OPERATIONS\Apps & Drivers\New Accounts Form Update\bsi" -Destination $rootPath
Copy-item -Recurse -Path "\\twb-files\Data\General\OPERATIONS\Apps & Drivers\New Accounts Form Update\shared" -Destination $rootPath
$pcname = hostname
$date = (Get-Date)
Add-Content -Path "\\twb-files\data\General\OPERATIONS\App_Install\S.xtras\NewAccts\Newaccounts-updated.txt" -Value "$pcname,$date" -PassThru
}#end Script block

Invoke-Command -Session $new {
Copy-Item -Credential $AdminCred -path  'C:\Support\NewAccts\New Accounts.zip'  -Destination C:\Cardinal\
Add-Content -Credential $AdminCred -Path "\\twb-files\data\General\OPERATIONS\App_Install\S.xtras\NewAccts\Newaccounts-updated.txt" -Value "$pcname,$date" -PassThru
}