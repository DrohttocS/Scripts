# Source
    $m_Srv = "c:\X9\"
# Dest Server
    $Proof_PC = "\\Pod1-1212\c$\Jaguar ITM\"
# Grab the newest files 
    $X9file = gci -Path $m_Srv -File |Sort-Object LastAccessTime -Descending |Select-Object -First 2
# Test If not there write no file found.
$Edate = Get-Date -Format "dddd MM dd yyyy"
If (!(Test-Path c:\x9\ATM* -PathType Leaf)){
      $emsg = "No ATM X9 File created $Edate"  
      Out-File "\\Pod1-1212\c$\Jaguar ITM\$emsg"
        }   
If (!(Test-Path c:\x9\ITM* -PathType Leaf)){
      $emsg = "No  ITM X9 File created $Edate"  
      Out-File "\\Pod1-1212\c$\Jaguar ITM\$emsg"
        }   

# // Copy Files to POD PC 
    $X9file | Copy-Item -Destination $Proof_PC

# File Cleanup - Move files to Archive folder YearMonth
Get-ChildItem -Path $m_Srv -File | ForEach-Object {
    $NewFolder = Join-Path -Path $m_Srv -ChildPath $_.LastWriteTime.ToString("yyyyMM")
    $FilePath = Join-Path -Path $NewFolder -ChildPath $_.Name
    if (-not (Test-Path $NewFolder)) {
       New-Item -Type Directory -Path $NewFolder
    }
    $_ | Move-Item -Destination $FilePath
} 



