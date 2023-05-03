# Audit
## vars
$dtpath = [Environment]::GetFolderPath("Desktop")
$date = (Get-Date).ToString("yyyyMMdd")
$groups = "Enterprise Admins", "Domain Admins", "Schema Admins","DNSAdmins"
 foreach($group in $groups){ 
                $file =$dtpath + '\' + $date +'-' + $group + '.txt'
                $y = "$group is empty"
                $x = $null           
                $x = Get-ADGroupMember -Identity $group  -Recursive | foreach{ get-aduser $_} | select SamAccountName,objectclass,name | sort SamAccountName
                     if($X -eq $null){write-host "$group is empty"; $y| Out-File $file
                     }else{$x; $x | Out-File $file }

            }


