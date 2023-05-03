


$ComputerName = $isup.dnshostname
cls


foreach ($comp in $ComputerName)
     {
         $output = @{ 'ComputerName' = $comp }
         $output.UserName = (Get-WmiObject -Class win32_computersystem -ComputerName $comp -ErrorAction SilentlyContinue).UserName
         [PSCustomObject]$output
     }