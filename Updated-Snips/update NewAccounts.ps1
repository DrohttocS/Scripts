$computers = "1xpvcx1-0413","1xpwcx1-0413","1xpxcx1-0413","abb-amp01-0118","amy712","bvoffice713","corvaccnt712","enagle-1212","ev-operations-w","fobopti380-pc","ggy7fz1-0114","h6rqcx1-0413","h6vpcx1-0413","h6xpcx1-0413","h6xqcx1-0413","ham-csr1-0916","ham-csr2-0118","mb-newaccounts3","mbw-nact01-0116","mbw-nact02-0116","mdb-nacc01-1117","mdb-nacc02-1117","mms-nact01-0416","pamela12","rduperron-1212","stevioffice713","sup-dsimo-0114","vdersam-0313"

# Special Accts  
# done in testing : "1xpvcx1-0413","1xpwcx1-0413","1xpxcx1-0413","abb-amp01-0118","amy712","bvoffice713","enagle-1212","fobopti380-pc","ggy7fz1-0114","h6rqcx1-0413","h6vpcx1-0413","h6xpcx1-0413","h6xqcx1-0413","ham-csr1-0916","mbw-nact01-0116","mbw-nact02-0116","mdb-nacc01-1117","mdb-nacc02-1117","mms-nact01-0416","pamela12","rduperron-1212","stevioffice713","sup-dsimo-0114","vdersam-0313"

foreach ($pc in $computers){
    $TestPath = "\\$pc\c$\cardinal\ "
if (Test-Connection -Computername $pc -BufferSize 16 -Count 1 -Quiet) {
        if ( $(Try { Test-Path $TestPath.trim() } Catch { $false }) ) {
                 write-host "$pc Path OK"

                 # get MSAccess.exe process 
                    $MSAccess = Get-Process MSAccess -ErrorAction SilentlyContinue
                    if ($MSAccess) {
                # try gracefully first
                    $MSAccess.CloseMainWindow()
                    echo "Stopped Access on $pc with grace" | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
                # kill after five seconds
                    Sleep 5
                    if (!$MSAccess.HasExited) {
                    $MSAccess | Stop-Process -Force
                    echo "Stopped Access on $pc forcefully" | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
                    }}
                    Remove-Variable MSAccess
                #Start copy and run process

                 Echo "$pc is online"  | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
                 echo "Step 1 - Copying file" | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
                 xcopy "\\bvb.local\Company\Data\General\OPERATIONS\Cardinal\!NewAccountsRepair\UpdatedCathyFixed.exe"   \\$pc\c$\cardinal\  | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
                 Echo "Starting Step 2 - Psexec on $pc" | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
                 C:\Support\PsExec.exe \\$pc "C:\cardinal\UpdatedCathyFixed.exe" -s
                 dir "\\$pc\c$\cardinal" | select name,lastwritetime | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
 }
            Else {
                     write-host "$pc No Access "
                     echo "$pc No Access " | Out-File -FilePath C:\Support\NoAcess_NewAccount_rnd4.txt -Append
                 }

    
     
    }
    else
    {Write-Host $pc is OFFline
     echo $pc | Out-File -FilePath C:\Support\NewAccount_rnd4.txt -Append
    }
}



