$isup=@()
$isDown=@()
$ping| ForEach {

        if (test-Connection -ComputerName $_ -Count 2 -Quiet ) {  
         
            write-Host "$_ is alive and Pinging " -ForegroundColor Green 
            $isup += $_
         
                    } else 
                     
                    { Write-Warning "$_ Not online or accessable"
             $isDown += $_
                    }     
         
} 


$isDown =  

$isup | ?{$_ -like "Xs*"}
