$ping = import-csv -Path C:\Temp\printers
$byName = foreach($H in $ping){
$h2p = $H.name
$i2p = $H.IP

Test-Connection -ComputerName $h2p -Count 1  | 
  select destination,status


$byIP = foreach($H in $ping){
$i2p = $H.IP

tnc -ComputerName $i2p  
}

echo yahoo.com microsoft.com | % -parallel { test-connection -count 1 $_ } | 
  select destination,status


  foreach($H in $ping){
$h2p | % -parallel { test-connection -count 1 $_ } |   select destination,status

}

$RDNS =  foreach($H in $ping){
$h2p = $H.name
$i2p = $H.IP
  Resolve-DnsName -Name $h2p -Server AMRNDSVPDC03
  }

  foreach($prn in $RDNS){
  $PRNIP = $prn.IPAddress
  Test-NetConnection -ComputerName $PRNIP

  }

$isup=@()
$isDown=@()


foreach($H in $ping){
$h2p = $H.name
$i2p = $H.IP

        if (test-Connection -ComputerName $h2p -Count 1 -Quiet ) {  
            $isup += $_
                    } else 
                    { Write-Warning "$h2p Not online or accessable"
             $Baddcs += $_
                    }     
}
