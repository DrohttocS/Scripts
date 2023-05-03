$outfile = "c:\admin\system_type.txt"
$Result = @()

Get-Content  C:\Admin\pinger\upyours.txt| ForEach-Object {
    if (Test-Connection $_ -Count 1 -Quiet) {
        $Chassis = Get-WmiObject Win32_SystemEnclosure -ComputerName $_ | Select ChassisTypes  
        If ($Chassis.ChassisTypes -eq "3"){$Chassis = "Desktop"}  
        ElseIf ($Chassis.ChassisTypes -eq "4"){$Chassis = "Low Profile Desktop"}  
        ElseIf ($Chassis.ChassisTypes -eq "5"){$Chassis = "Pizza Box"}  
        ElseIf ($Chassis.ChassisTypes -eq "6"){$Chassis = "Mini Tower"}  
        ElseIf ($Chassis.ChassisTypes -eq "7"){$Chassis = "Tower"}  
        ElseIf ($Chassis.ChassisTypes -eq "8"){$Chassis = "Portable"}  
        ElseIf ($Chassis.ChassisTypes -eq "9"){$Chassis = "Laptop"}  
        ElseIf ($Chassis.ChassisTypes -eq "10"){$Chassis = "Notebook"}  
        ElseIf ($Chassis.ChassisTypes -eq "11"){$Chassis = "Hand Held"}  
        ElseIf ($Chassis.ChassisTypes -eq "12"){$Chassis = "Docking Station"}  
        ElseIf ($Chassis.ChassisTypes -eq "13"){$Chassis = "All in One"}  
        ElseIf ($Chassis.ChassisTypes -eq "14"){$Chassis = "Sub Notebook"}  
        ElseIf ($Chassis.ChassisTypes -eq "15"){$Chassis = "Space-Saving"}   
        ElseIf ($Chassis.ChassisTypes -eq "16"){$Chassis = "Lunch Box"}  
        ElseIf ($Chassis.ChassisTypes -eq "17"){$Chassis = "Main System Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "18"){$Chassis = "Expansion Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "19"){$Chassis = "Sub Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "20"){$Chassis = "Bus Expansion Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "21"){$Chassis = "Peripheral Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "22"){$Chassis = "Storage Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "23"){$Chassis = "Rack Mount Chassis"}  
        ElseIf ($Chassis.ChassisTypes -eq "24"){$Chassis = "Sealed-Case PC"}  
        Else {$Chassis = "Chassis Type: $($Chassis.ChassisTypes) is Unknown"}  
        
        $Result += New-Object PSObject -Property @{
            Computer = $_
            ChassisType = $Chassis
        }
    }
    Else
    {   $Result += New-Object PSObject -Property @{
            Computer = $_
            ChassisType = "Computer Offline"
        }
    }
}

$Result | Select Computer,ChassisType | Export-Csv -Path $outfile -NoTypeInformation
 