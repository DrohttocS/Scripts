﻿$computer = "D-GIPCWL004"


Function Get-Laptop
{
 Param(
 
 )
 $isLaptop = $false
 if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | 
    Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 `
    -or $_.chassistypes -eq 14})
   { $isLaptop = $true }
 if(Get-WmiObject -Class win32_battery -ComputerName $computer) 
   { $isLaptop = $true }
 $isLaptop
} # end function Get-Laptop




# *** entry point to script ***

If(get-Laptop) { "$computer is a laptop" }
else { "$computer  not a laptop"}