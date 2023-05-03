﻿Get-ADComputer -Filter {operatingsystem -like “*server*”} | select “name” | foreach {$_.name} {.\get-ipdetails.ps1 $_.name | out-gridview