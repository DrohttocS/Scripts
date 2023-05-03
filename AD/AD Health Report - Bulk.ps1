#######
#
#  REQUIRES Module PSWriteHTML
#  Install-Module -Name PSWriteHTML -AllowClobber -Force  
# Error fix .... [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#
$error.Clear()
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$starttime = Get-Date 
$Baddcs =@()
$isup=@()
$isDown=@()
cls
$dcs | ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            $isup += $_
                    } else 
                    { Write-Warning "$_ Not online or accessable"
             $Baddcs += $_
                    }     
}

$dcs = $isup
$session = New-PSSession  -ComputerName $dcs -Credential $AdminCred

$res = Invoke-Command -Session $session  -ScriptBlock{
         ####################Netlogons status##################
         $netlogonT = dcdiag /test:netlogons | select-string -Pattern "test NetLogons" | out-string
         $netlogonT = ($netlogonT).replace('.','')
         $netlogonT = $netlogonT -split ' '
         $netlogonT = $netlogonT[11]

         ######################################################
         ####################Replications status##################
         $ReplicationT = dcdiag /test:Replications | select-string -Pattern " test Replications" | out-string
         $ReplicationT = ($ReplicationT).replace('.','')
         $ReplicationT = $ReplicationT -split ' '
         $ReplicationT = $ReplicationT[11]
         ######################################################
         ####################Services status##################
         $ServicesT = dcdiag /test:Services | select-string -Pattern " test Services" | out-string
         $ServicesT = ($ServicesT).replace('.','')
         $ServicesT = $ServicesT -split ' '
         $ServicesT = $ServicesT[11]
         ######################################################
         ####################Advertising status##################
         $AdvertisingT = dcdiag /test:Advertising | select-string -Pattern " test Advertising" | out-string
         $AdvertisingT = ($AdvertisingT).replace('.','')
         $AdvertisingT = $AdvertisingT -split ' '
         $AdvertisingT = $AdvertisingT[11]
         ######################################################
         ####################Intersite status##################
         $IntersiteT = dcdiag /test:Intersite | select-string -Pattern " test Intersite" | out-string
         $IntersiteT = ($IntersiteT).replace('.','')
         $IntersiteT = $IntersiteT -split ' '
         $IntersiteT = $IntersiteT[11]
         ######################################################
         ####################KccEvent status##################
         $KccEventT = dcdiag /test:KccEvent | select-string -Pattern " test KccEvent" | out-string
         $KccEventT = ($KccEventT).replace('.','')
         $KccEventT = $KccEventT -split ' '
         $KccEventT = $KccEventT[11]
         ######################################################
          ####################Topology status##################
         $TopologyT = dcdiag /test:Topology | select-string -Pattern " test Topology" | out-string
         $TopologyT = ($TopologyT).replace('.','')
         $TopologyT = $TopologyT -split ' '
         $TopologyT = $TopologyT[11]
         ######################################################
          ####################SystemLog status##################
         $SystemLogT = dcdiag /test:SystemLog | select-string -Pattern " test SystemLog" | out-string
         $SystemLogT = ($SystemLogT).replace('.','')
         $SystemLogT = $SystemLogT -split ' '
         $SystemLogT = $SystemLogT[11]
         ######################################################
         ####################KnowsOfRoleHolders status##################
         $KnowsOfRoleHoldersT = dcdiag /test:KnowsOfRoleHolders | select-string -Pattern "Starting test: KnowsOfRoleHolders" -Context 0,2 | out-string
         $KnowsOfRoleHoldersT = ($KnowsOfRoleHoldersT).replace('.','')
         $KnowsOfRoleHoldersT = $KnowsOfRoleHoldersT -split ' '
         $KnowsOfRoleHoldersT = $KnowsOfRoleHoldersT[24]
         ######################################################
        New-Object PSObject -Property ([ordered]@{
            Identity          = $ENV:COMPUTERNAME
            NetlogonService   = get-service -Name "Netlogon" -ErrorAction SilentlyContinue | select -ExpandProperty status
            NTDSService       = get-service -Name "NTDS" -ErrorAction SilentlyContinue | select -ExpandProperty status
            DNSServiceStatus  = get-service -Name "DNS" -ErrorAction SilentlyContinue | select -ExpandProperty status
            "Netlogons Test"     = $netlogonT
            "Replication Test"   = $ReplicationT
            "Services Test"      = $ServicesT
            "Advertising Test"   = $AdvertisingT 
            "Intersite Test"     = $IntersiteT 
            "KCC Test"           = $KccEventT 
            "Topology Test"      = $TopologyT
            "SystemLog Test"     = $SystemLogT
            "FSMO Test"          = $KnowsOfRoleHoldersT
        })
        }
$data = $res|sort Identity|Select-Object "Identity","NetlogonService","NTDSService","DNSServiceStatus","Netlogons Test","Replication Test","Services Test","Advertising Test","Intersite Test","kCC Test","Topology Test","SystemLog Test","FSMO Test"

Remove-PSSession $session
# Get the replication info.
$myRepInfo = @(repadmin /replsum * /bysrc /bydest /sort:delta)
 
# Initialize our array.
$cleanRepInfo = @()
   # Start @ #10 because all the previous lines are junk formatting
   # and strip off the last 4 lines because they are not needed.
    for ($i=10; $i -lt ($myRepInfo.Count-4); $i++) {
            if($myRepInfo[$i] -ne ""){
            # Remove empty lines from our array.
            $myRepInfo[$i] -replace '\s+', " "           
            $cleanRepInfo += $myRepInfo[$i]            
            }
            }           
$finalRepInfo = @()  
            foreach ($line in $cleanRepInfo) {
            $splitRepInfo = $line -split '\s+',8
            if ($splitRepInfo[0] -eq "Source") { $repType = "Source" }
            if ($splitRepInfo[0] -eq "Destination") { $repType = "Destination" }
           
            if ($splitRepInfo[1] -notmatch "DSA") {      
            # Create an Object and populate it with our values.
           $objRepValues = New-Object System.Object
               $objRepValues | Add-Member -type NoteProperty -name DSAType -value $repType # Source or Destination DSA
               $objRepValues | Add-Member -type NoteProperty -name Hostname  -value $splitRepInfo[1] # Hostname
               $objRepValues | Add-Member -type NoteProperty -name Delta  -value $splitRepInfo[2] # Largest Delta
               $objRepValues | Add-Member -type NoteProperty -name Fails -value $splitRepInfo[3] # Failures
               #$objRepValues | Add-Member -type NoteProperty -name Slash  -value $splitRepInfo[4] # Slash char
               $objRepValues | Add-Member -type NoteProperty -name Total -value $splitRepInfo[5] # Totals
               $objRepValues | Add-Member -type NoteProperty -name PctError  -value $splitRepInfo[6] # % errors  
               $objRepValues | Add-Member -type NoteProperty -name ErrorMsg  -value $splitRepInfo[7] # Error code
          
            # Add the Object as a row to our array   
            $finalRepInfo += $objRepValues
           
            }
            }






               
 #############################    EMAIL Loop   ################################
        $From = "no-replyd@nidec-motor.com"
        $To = "opsys@nidec-motor.com"  
        $Date = (Get-Date -UFormat "%A %m/%d/%Y %R %Z")
        $subject = "NIDECDS.COM Active Directory Health Summary"
      # $Body = $frag1 | convertto-html @convertParams | Out-String
        $SMTPServer = "172.16.10.36"
        $SMTPPort = "587"
      #  Send-MailMessage -From $From -to $To -Subject $Subject `
      #  -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort `
        
##############################################################################
$endtime = (Get-Date) - $starttime
$Baddcs += Compare-Object $dcs $session.computername | Select-Object -ExpandProperty inputobject
$BaddcsCount = $Baddcs.count
Email {
    EmailHeader {
        EmailFrom -Address $From
        EmailTo -Addresses $To
        EmailServer -Server $SMTPServer -Port $SMTPPort
        EmailSubject -Subject $subject
    }

    EmailBody -FontFamily 'Calibri' -Size 12 {
        EmailText -Text "ActiveDirectory Health check ", $Date -Color Blue, None

        if ($BaddcsCount -ge 1)
        {EmailText -Text "Could not connect to the follow: $Baddcs" -Color BrickRed -FontSize 16 -FontWeight bold
            
        }
        EmailTable -DataTable $data {
          EmailTableHeader -Names 'NetlogonService','NTDSService', 'DNSServiceStatus' -Title 'Services' -Alignment center -Color White -BackGroundColor Gray
          EmailTableHeader -Names "Netlogons Test","Replication Test","Services Test","Advertising Test","Intersite Test","kCC Test","Topology Test","SystemLog Test","FSMO Test" -Title 'dcdiag test results' -Alignment center -Color White -BackGroundColor Gray
            EmailTableCondition -ComparisonType 'string' -Name 'NTDSService' -Operator eq -Value 'Running' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'NTDSService' -Operator eq -Value 'Stopped' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'DNSServiceStatus' -Operator eq -Value 'Running' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'DNSServiceStatus' -Operator eq -Value 'Stopped' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'NetlogonService' -Operator eq -Value 'Running' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'NetlogonService' -Operator eq -Value 'Stopped' -BackgroundColor BrickRed -Color White -Inline -Row

            EmailTableCondition -ComparisonType 'string' -Name 'Netlogons Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Netlogons Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'Replication Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Replication Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'Services Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Services Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'Advertising Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Advertising Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'Intersite Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Intersite Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'kCC Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'kCC Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'Topology Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Topology Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row
            EmailTableCondition -ComparisonType 'string' -Name 'SystemLog Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'SystemLog Test' -Operator eq -Value 'Failed' -BackgroundColor MoonYellow -Color Black -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'FSMO Test' -Operator eq -Value 'passed' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'FSMO Test' -Operator eq -Value 'Failed' -BackgroundColor BrickRed -Color White -Inline -Row

            EmailTableCondition -ComparisonType 'string' -Name 'Pingable' -Operator eq -Value 'True' -BackgroundColor Green -Color White -Inline
            EmailTableCondition -ComparisonType 'string' -Name 'Pingable' -Operator ne -Value 'True' -BackgroundColor Red -Color White -Inline
         
           
        } -HideFooter
    EmailText -LineBreak 
          EmailTable -DataTable $finalRepInfo  {
                    EmailTableHeader -Names 'DSAType','Hostname', 'Delta', 'Fails','Total','PctError','ErrorMsg' -Title 'repadmin /replsum' -Alignment center -Color White -BackGroundColor Gray
                                    EmailTableCondition -ComparisonType 'string' -Name 'PctError' -Operator ge -Value "1" -BackgroundColor BrickRed -Color White -Inline -FontWeight bold -Row
                                    EmailTableCondition -ComparisonType 'string' -Name 'Fails' -Operator ge -Value "1" -BackgroundColor BrickRed -Color White -Inline -FontWeight bold -Row
          }


        EmailText -LineBreak
        EmailTextBox {
               "This report was generated on: $env:COMPUTERNAME"
               "Running time: $endtime "
                        
        }
    }
    }


