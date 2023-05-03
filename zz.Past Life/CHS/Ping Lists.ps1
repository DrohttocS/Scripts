"MA08802"",""VO08914"",""VH15945"",""VL6529"",""SO15750V"",""MA011204"",""REO8685"",""SO089791"",""MA15873"",""S015961"",""MA08929"",""MA08960"",""CC08075"",""VL08852"",""REO89698"",""SO089791"",""SO08540"",""IC15980"",""CD08120"",""MA011233"",""RE08695"



#### Provide the computer name in $computername variable 
 
$ServerName = "EVR-TLRDU-1218","EVR-TELLER00","EVR-BRDRM1-0119","HAM-TELL19-0613","HAM-JYOUNK-0616","HS1-TLR04-0218","TELLERADMIN713","HS1-CSPI-0416","HAM-TLR05-02118","EVR-TLR01-0118","EB-DRIVEUP-W7","SERVER2K8","WESTONECONF","BDC","JEVERETT-1212","HAM-CSR3-1218","HAM-DATA3X-1118","HAM-BOOK6-0713","HAM-BMURR-1218"

   $isup=@()
##### Script Starts Here ######  
 
foreach ($Server in $ServerName) { 
 
        if (test-Connection -ComputerName $Server -Count 1 -Quiet ) {  
         
            write-Host "$Server is alive and Pinging " -ForegroundColor Green 
            $isup += $Server
         
                    } else 
                     
                    { Write-Warning "$Server Not online or accessable via SCCM. Need Desktop or phyically verify pc and install." 
             
                    }     
         
} 
 