# +--------------------------------------------------------+
# | Computer Mentors System Information V5.0               |
# | Code adapted from:                                     |
# |          Powershell PC Info Script V1.0b               | 
# |             Coded By:Trenton Ivey(kno)                 | 
# |                    hackyeah.com                        |
# | Incorporated Coding changes recommed by Cafed00d @ WSL |
# +--------------------------------------------------------+

param (
  $compname = "localhost"  #Default if no Compname Arg.
)
  
$enclosureNames = (
  "unknown",  # 0
  "Other" ,
  "Unknown" ,
  "Desktop" ,
  "Low Profile Desktop" ,
  "Pizza Box" ,  #5
  "Mini Tower" ,
  "Tower" ,
  "Portable" ,
  "Laptop" ,
  "Notebook" , #10
  "Hand Held" ,
  "Docking Station" ,
  "All-in-One" ,
  "Sub Notebook" ,
  "Space Saving" ,  #15
  "Lunch Box" ,
  "Main System Chassis",
  "Expansion Chassis",
  "Sub-Chassis",
  "Bus Expansion Chassis", #20
  "Peripheral Chassis" ,
  "Storage Chassis" ,
  "Rack Mount Chassis" ,
  "Sealed-Case PC" #24
)
     
      Clear-Host
      "General Computer Information:`n"
      # Create Table
       $CITable = New-Object system.Data.DataTable "Computer Information"
#Create Columns for table 
       $CITcol1 = New-Object system.Data.DataColumn Item,([string])       
       $CITcol2 = New-Object system.Data.DataColumn Value,([string])
#Add Columns to table
       $CITable.columns.add($CITcol1)
       $CITable.columns.add($CITcol2)
      $ComputerSysObj = get-WMIObject -computer $compname Win32_ComputerSystem    
#Create Row Variable 
      $CITRow = $CITable.NewRow()
#Assign items to row variable
      $CITRow.Item = 'Computer Name' 
      $CITRow.Value = $ComputerSysObj.Name
#Add Row to Table using Row Variable
      $CITable.Rows.Add($CITRow)

      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Current User ID'
      $CITRow.Value = $ComputerSysObj.Username
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Domain Name'
      $CITRow.Value = $ComputerSysObj.Domain
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Manufacturer'
      $CITRow.Value = $ComputerSysObj.Manufacturer
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Model'
      $CITRow.Value = $ComputerSysObj.Model
      $CITable.Rows.Add($CITRow)

      $enclosure = get-wmiobject -computer $compname Win32_SystemEnclosure
      $ChassisNo = $enclosure.ChassisTypes[0]
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Enclosure Type'
      $CITRow.Value = if ($ChassisNo -ge $enclosureNames.length) {
                          "Currently Unassigned"
                      } 
                      else {
                          $enclosureNames[$ChassisNo]
                      }
      $CITable.Rows.Add($CITRow)

      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'System Type'
      $CITRow.Value = $ComputerSysObj.SystemType
      $CITable.Rows.Add($CITRow)
      
      $BIOSObject = get-WMIObject -computer $compname Win32_BIOS
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Serial Number'
      $CITRow.Value = $BIOSObject.SerialNumber
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'BIOS Name'
      $CITRow.Value = $BIOSObject.Name
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '     Version'
      $CITRow.Value = $BIOSObject.SMBIOSBIOSVersion
      $CITable.Rows.Add($CITRow)
      
      $OS_Object = get-WMIObject -computer $compname Win32_OperatingSystem
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'OS Name'
      $CITRow.Value = $OS_Object.Caption
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Serial Number'
      $CITRow.Value = $OS_Object.SerialNumber
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'OS Bit Width'
      $CITRow.Value = $OS_Object.OSArchitecture
      $CITable.Rows.Add($CITRow)
 
      $localdatetime = $OS_Object.ConvertToDateTime($OS_Object.LocalDateTime) 
      $lastbootuptime = $OS_Object.ConvertToDateTime($OS_Object.LastBootUpTime) 
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Time Current'
      $CITRow.Value = $LocalDateTime
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '     Last Boot'
      $CITRow.Value = $LastBootUpTime
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '     Total Up'
      $CITRow.Value = $localdatetime - $lastbootuptime
      
      $Processor_Object = get-WMIObject -computer $compname Win32_Processor
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = 'Processor Name'
      $CITRow.Value = $Processor_Object.Name
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '          Info'
      $CITRow.Value = $Processor_Object.Caption
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '          Maker'
      $CITRow.Value = $Processor_Object.Manufacturer
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '          ID'
      $CITRow.Value = $Processor_Object.ProcessorId
      $CITable.Rows.Add($CITRow)
      
      $CITRow = $CITable.NewRow()
      $CITRow.Item = '          Cores'
      $CITRow.Value = $Processor_Object.NumberofCores
      $CITable.Rows.Add($CITRow)

      $CITRow = $CITable.NewRow()
      $CITRow.Item = '  Address Width'
      $CITRow.Value = $Processor_Object.AddressWidth
      $CITable.Rows.Add($CITRow)
      
#Output table
      $fmt = @{Expression={$_.Item};Label="Item";width=20},
             @{Expression={$_.Value};Label="Value";Width=40}
             
      $CITable | Select-Object Item,Value | Format-Table $fmt
      
#PC Printer Information 
            "Installed Printer Information:"
            get-WMIObject -computer $compname Win32_Printer | Select-Object DeviceID,DriverName, PortName | Format-Table -autosize
            
#Disk Info 
            "Drive Information:"
            $fmt = @{Expression={$_.Name};Label="Drive Letter";width=12},
                     @{Expression={$_.VolumeName};Label="Vol Name";Width=15},
                     @{Expression={ '{0:#,000.00}' -f ($_.Size/1gb)};Label="Disk Size / GB";width=14},
                     @{Expression={ '{0:#,000.00}' -f ($_.FreeSpace/1gb)};Label="Free Space / GB";width=15}
                     
            $Disk_Object = get-WMIObject -computer $compname Win32_logicaldisk 
            $Disk_Object | Format-Table $fmt

#Memory Info 
            "Memory Information:"
            $fmt = @{Expression={$_.Speed};Label="Speed";width=20},
                   @{Expression={$_.DataWidth};Label="Data Width";width=10},
                   @{Expression={ '{0:#.00}' -f ($_.Capacity/1gb)};Label="Module Size / GB";width=16},
                   @{Expression={$_.DeviceLocator};Label="Slot";width=6},
                   @{Expression={$_.SerialNumber};Label="Serial No."}

            $Mem_Object = get-WMIObject -computer $compname Win32_PhysicalMemory 
            $Mem_Object | Format-Table $fmt

#Monitor Info 
            "Monitor Information:" 
            #Turn off Error Messages 
            $ErrorActionPreference_Backup = $ErrorActionPreference 
            $ErrorActionPreference = "SilentlyContinue" 
 
 
            $keytype=[Microsoft.Win32.RegistryHive]::LocalMachine 
            if($reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($keytype,$compname)){ 
                #Create Table To Hold Info 
                $montable = New-Object system.Data.DataTable "Monitor Info" 
                #Create Columns for Table 
                $moncol1 = New-Object system.Data.DataColumn Name,([string]) 
                $moncol2 = New-Object system.Data.DataColumn Serial,([string]) 
                $moncol3 = New-Object system.Data.DataColumn Ascii,([string]) 
                #Add Columns to Table 
                $montable.columns.add($moncol1) 
                $montable.columns.add($moncol2) 
                $montable.columns.add($moncol3) 
 
 
 
                $regKey= $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\DISPLAY" ) 
                $HID = $regkey.GetSubKeyNames() 
                foreach($HID_KEY_NAME in $HID){ 
                    $regKey= $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID_KEY_NAME" ) 
                    $DID = $regkey.GetSubKeyNames() 
                    foreach($DID_KEY_NAME in $DID){ 
                        $regKey= $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID_KEY_NAME\\$DID_KEY_NAME\\Device Parameters" ) 
                        $EDID = $regKey.GetValue("EDID") 
                        foreach($int in $EDID){ 
                            $EDID_String = $EDID_String+([char]$int) 
                        } 
                        #Create new row in table 
                        $monrow=$montable.NewRow() 
                         
                        #MonitorName 
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFC + [char]0x00            
                        $matchfound = $EDID_String -match "$checkstring([\w ]+)" 
                        if($matchfound){$monrow.Name = [string]$matches[1]} else {$monrow.Name = '-'} 
 
                         
                        #Serial Number 
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFF + [char]0x00            
                        $matchfound =  $EDID_String -match "$checkstring(\S+)" 
                        if($matchfound){$monrow.Serial = [string]$matches[1]} else {$monrow.Serial = '-'} 
                                                 
                        #AsciiString 
                        $checkstring = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFE + [char]0x00            
                        $matchfound = $EDID_String -match "$checkstring([\w ]+)" 
                        if($matchfound){$monrow.Ascii = [string]$matches[1]} else {$monrow.Ascii = '-'}          
 
                                 
                        $EDID_String = '' 
                         
                        $montable.Rows.Add($monrow) 
                    }   # End - foreach($DID_KEY_NAME in $DID)
                    
                } # End - foreach($HID_KEY_NAME in $HID)
                
                $montable | select-object  -unique Serial,Name,Ascii | Where-Object {$_.Serial -ne "-"} | Format-Table 
                 
            }   # End If
            
            else {  
                Write-Host "Access Denied - Check Permissions" 
            }