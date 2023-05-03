Get-WinEvent -FilterHashtable @{logname='system' ; starttime='02/06/2019 09:45:00 pm'; 
    endtime= '02/06/2019 10:15:00 pm' } | ft -AutoSize -Wrap


$datea = Read-Host "date from"
$dateb = Read-Host "date to"
$saveto = Read-Host "save output to"
Get-EventLog -InstanceId 500 -LogName Security -After $dateb -Before $datea | Format-Lis



get-winevent -listlog * -ea 0 | 
foreach { 
  get-winevent @{logname=$_.logname; Data='bvb\jhowe' ;starttime='02/06/2019 09:45:00 pm'; 
    endtime= '02/06/2019 10:15:00 pm'} -ea 0  | fl

}


