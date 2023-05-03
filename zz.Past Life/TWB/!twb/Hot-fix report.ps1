$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$ADPC = Get-ADComputer -Filter {(Enabled -eq $true)} 
$isup=@()
$isDown=@()
cls
$ADPC.name | ForEach {

        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
         
            write-Host "$_ is alive and Pinging " -ForegroundColor Green 
            $isup += Get-ADComputer -Identity $_
         
                    } else 
                     
                    { Write-Warning "$_ Not online or accessable"
             $isDown += $_
                    }     
         
}




$Hosts = $isup.name
$isDown.count


Invoke-Command -ComputerName $Hosts -Credential $AdminCred -ScriptBlock {
    Get-HotFix | Where-Object {
        $_.InstalledOn -gt ((Get-Date).AddDays(-30))
    } | Select-Object -Property PSComputerName, Description, HotFixID, InstalledOn
} | Format-Table -AutoSize |
Out-File -Encoding utf8 -FilePath 'c:\SUPport\Recent_OS_Updates.txt' -Append -ErrorAction SilentlyContinue


function Get-SoftwareUpdate {
  param(
  $ComputerName, 
  $Credential
  )

  $code = {
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $HistoryCount = $Searcher.GetTotalHistoryCount()
    $Searcher.QueryHistory(1,$HistoryCount) | 
      Select-Object Date, Title, Description
  } 

  $pcname = @{
    Name = 'Machine'
    Expression = { $_.PSComputerName }
  }

  Invoke-Command $code @psboundparameters | 
    Select-Object $pcname, Date, Title, Description
}
