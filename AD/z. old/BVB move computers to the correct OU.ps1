################################################################################ 
# PowerShell routine to move Windows Computers into OU structure based on IP # 
################################################################################ 
 
# Requires Active Directory 2008 R2 and the PowerShell ActiveDirectory module 
 
##################### 
# Environment Setup # 
##################### 
 
#Add the Active Directory PowerShell module 
Import-Module ActiveDirectory 
 
#Set the threshold for an "old" computer which will be moved to the Disabled OU 
#$old = (Get-Date).AddDays(-0) # Modify the -60 to match your threshold  
 
#Set the threshold for an "very old" computer which will be deleted 
#$veryold = (Get-Date).AddDays(-0) # Modify the -90 to match your threshold  
 
 
############################## 
# Set the Location IP ranges # 
############################## 

$Site1IPRange = "192.168.38."	# 192.168.38.0/24	Dearborn
$Site2IPRange = "192.168.3."	# 192.168.3.0/24	Bonner
$Site3IPRange = "192.168.1."	# 192.168.1.0/24	Lolo
$Site4IPRange = "192.168.0."	# 192.168.0.0/24	Airway
$Site5IPRange = "192.168.5."	# 192.168.5.0/24	Frenchtown
$Site6IPRange = "192.168.6."	# 192.168.6.0/24	St. Regis 
$Site7IPRange = "192.168.4."	# 192.168.4.0/24	Superior
$Site8IPRange = "192.168.9."	# 192.168.9.0/24	Broadway
$Site9IPRange = "192.168.18."	# 192.168.18.0/24	Downtown
$Site10IPRange = "172.18.4." 	# 172.18.4.0/24		Corvallis
$Site11IPRange = "192.168.28."	# 192.168.28.0/24	Evergreen
$Site12IPRange = "192.168.8."	# 192.168.8.0/24	Kalispell
$Site13IPRange = "10.0.1."      # 10.0.1.0/     	Pickney
$Site14IPRange = "172.18.3."	# 172.18.3.0/24		HS1
$Site15IPRange = "172.18.2"	    # 172.18.2.0/24		SS1
$Site16IPRange = "172.18.5."	# 172.18.5.0/24		Autobank

 
######################## 
# Set the Location OUs # 
######################## 
 
# Disabled OU 
$DisabledDN = "OU=test,OU=Family of Banks Computers,DC=bvb,DC=local" 
 
# OU Locations 

$Site1DN = "OU=Dearborn,OU=Family of Banks Computers,DC=bvb,DC=local"            
$Site2DN = "OU=Bonner,OU=Family of Banks Computers,DC=bvb,DC=local"             
$Site3DN = "OU=Lolo,OU=Family of Banks Computers,DC=bvb,DC=local"                
$Site4DN = "OU=Airway,OU=Family of Banks Computers,DC=bvb,DC=local"              
$Site5DN = "OU=Frenchtown,OU=Family of Banks Computers,DC=bvb,DC=local"          
$Site6DN = "OU=St. Regis,OU=Family of Banks Computers,DC=bvb,DC=local"           
$Site7DN = "OU=Superior,OU=Family of Banks Computers,DC=bvb,DC=local"            
$Site8DN = "OU=Broadway,OU=Family of Banks Computers,DC=bvb,DC=local"            
$Site9DN = "OU=Downtown,OU=Family of Banks Computers,DC=bvb,DC=local"            
$Site10DN = "OU=Corvallis,OU=Hamilton,OU=Family of Banks Computers,DC=bvb,DC=local"           
$Site11DN = "OU=Evergreen,OU=Family of Banks Computers,DC=bvb,DC=local"           
$Site12DN = "OU=Kalispell,OU=Family of Banks Computers,DC=bvb,DC=local"           
$Site13DN = "OU=Pinckney,OU=Hamilton,OU=Family of Banks Computers,DC=bvb,DC=local" 
$Site14DN = "OU=HS1,OU=Hamilton,OU=Family of Banks Computers,DC=bvb,DC=local"     
$Site15DN = "OU=SS1,OU=Hamilton,OU=Family of Banks Computers,DC=bvb,DC=local"     
$Site16DN = "OU=Autobank,OU=Hamilton,OU=Family of Banks Computers,DC=bvb,DC=local"
 
############### 
# The process # 
############### 
 
# Query Active Directory for Computers running Windows 7 (Any version) and move the objects to the correct OU based on IP 
#$Computers = Get-ADComputer -SearchBase "OU=Staging,OU=Family of Banks Computers,DC=bvb,DC=local" -SearchScope OneLevel -Filter {enabled -eq $True -and OperatingSystem -NotLike "*Server*"} -Properties * | sort name
$Computers = Get-ADComputer -SearchBase "OU=Family of Banks Computers,DC=bvb,DC=local"  -Filter {enabled -eq $True -and OperatingSystem -NotLike "*Server*"} -Properties * | sort name
ForEach ($computer in $Computers) { 
 
    # Ignore Error Messages and continue on 
    trap [System.Net.Sockets.SocketException] { continue; } 
 
    # Set variables for Name and current OU 
    $ComputerName = $computer.Name 
    $ComputerDN = $computer.distinguishedName 
    $ComputerPasswordLastSet = $computer.PasswordLastSet 
    $ComputerContainer = $ComputerDN.Replace( "CN=$ComputerName," , "") 
    $ComputerIP = $computer.IPv4Address
    # If the computer is more than 90 days off the network, remove the computer object 
    #if ($ComputerPasswordLastSet -le $veryold) {  
    #    Remove-ADObject -Identity $ComputerDN 
    #} 
 
    # Check to see if it is an "old" computer account and move it to the Disabled\Computers OU 
    #if ($ComputerPasswordLastSet -le $old) {  
    #    $DestinationDN = $DisabledDN 
    #    Move-ADObject -Identity $ComputerDN -TargetPath $DestinationDN 
    #} 
 
    # Query DNS for IP  
    # First we clear the previous IP. If the lookup fails it will retain the previous IP and incorrectly identify the subnet 
    $IP = $NULL 
    $IP = $Computer.IPv4Address -split "\d{1,3}$"
 
    # Use the $IPLocation to determine the computer's destination network location 
    # 
    # 
    if ($IP -match $Site1IPRange) { 
        $DestinationDN = $Site1DN 
    } 
    ElseIf ($IP -match $Site2IPRange) { 
        $DestinationDN = $Site2DN 
    } 
    ElseIf ($IP -match $Site3IPRange) { 
        $DestinationDN = $Site3DN 
    }
    ElseIf ($IP -match $Site4IPRange) { 
        $DestinationDN = $Site4DN 
    }
    ElseIf ($IP -match $Site5IPRange) { 
        $DestinationDN = $Site5DN 
    }
    ElseIf ($IP -match $Site6IPRange) { 
        $DestinationDN = $Site6DN 
    }
    ElseIf ($IP -match $Site7IPRange) { 
        $DestinationDN = $Site7DN 
    }
    ElseIf ($IP -match $Site8IPRange) { 
        $DestinationDN = $Site8DN 
    }
    ElseIf ($IP -match $Site9IPRange) { 
        $DestinationDN = $Site9DN 
    }
    ElseIf ($IP -match $Site10IPRange) { 
        $DestinationDN = $Site10DN 
    }
    ElseIf ($IP -match $Site11IPRange) { 
        $DestinationDN = $Site11DN 
    }
    ElseIf ($IP -match $Site12IPRange) { 
        $DestinationDN = $Site12DN 
    }
    ElseIf ($IP -match $Site13IPRange) { 
        $DestinationDN = $Site13DN 
    }
    ElseIf ($IP -match $Site14IPRange) { 
        $DestinationDN = $Site14DN 
    }
    ElseIf ($IP -match $Site15IPRange) { 
        $DestinationDN = $Site15DN 
    }
    ElseIf ($IP -match $Site16IPRange) { 
        $DestinationDN = $Site16DN 
    }
    Else { 
        # If the subnet does not match we should not move the computer so we do Nothing 
        $DestinationDN = $ComputerContainer
        Write-host  "`n$ComputerName - Can't determine subnet. $IP`n"
    } 
 


    # Move the Computer object to the appropriate OU 
    # If the IP is NULL we will trust it is an "old" or "very old" computer so we won't move it again 
    if ($IP -ne $NULL) { 
        
        if($ComputerContainer -eq $DestinationDN) {
        Write-Host "`n`n$ComputerName is in the correct OU.`n"
        }
        
        Else{
         TRY{
                Write-host "`nMoving - `n $ComputerName in $ComputerContainer moved to $DestinationDN"
            #    Move-ADObject -Identity $ComputerDN -TargetPath $DestinationDN -ea SilentlyContinue 
            }
        catch{
                Write-Warning $Error[0]
            }
      }
    } 
}
