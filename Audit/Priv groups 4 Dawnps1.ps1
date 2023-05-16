# Audit
## vars
$dtpath = [Environment]::GetFolderPath("Desktop")
$date = (Get-Date).ToString("yyyyMMdd")
$groups = "Enterprise Admins", "Domain Admins", "Schema Admins","DNSAdmins"
 foreach($group in $groups){ 
                $file =$dtpath + '\' + $date +'-' + $group + '.txt'
                $y = "$group is empty"
                $x = $null           
                $x = Get-ADGroupMember -Identity $group  -Recursive | foreach{ get-aduser $_ -Properties Description } | select SamAccountName,objectclass,name,Description | sort SamAccountName
                     if($X -eq $null){write-host "$group is empty"; $y| Out-File $file
                     }else{write-host "$group"; $x; $x | Out-File $file }

            }


