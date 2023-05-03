$isup=@()
$isDown=@()
$OUpath = 'OU=TWB Computers,DC=bvb,DC=local'
$sinv = @()
$Computerlist = Get-ADComputer -Filter * -Properties * -SearchBase $OUpath | Select-object DNSHostName #,Name, IPv4Address | sort Name, IPv4Address
$Computerlist = $Computerlist.dnshostname


cls
        ForEach ($pc in $computerlist){
            #Pings machine's found in text file
            if (!(test-Connection -ComputerName $pc -BufferSize 16 -Count 1 -ea 0 -Quiet))
            {
                Write-Output "$pc  Offline"
            }
            Else
            {
             #Providing the machine is reachable 
             #Checks installed programs for products that contain New Accounts in the name
             Try { $sinv += Get-WMIObject -Class win32_product -Filter {Name like "%Accounts%"} -ComputerName $pc -ErrorAction STOP | Select-Object -Property PSComputerName,Name,Version }
             Catch {#If an error, do this instead
                    Write-Output "$pc Is borked"}
             #EndofElse
             }
        #EndofForEach
        }

        $sinv | Sort PSComputername       | Out-GridView
