$file = 'C:\Windows\system32\LogFiles\in*.log'

#If the file does not exist, create it.
if (-not(Test-Path -Path $file -PathType Leaf)) {
     try {cls
            Write-Warning "File does not exists!"
     }
     catch {
         throw $_.Exception.Message
     }
 }
 else {cls
     Write-Host "Log file found do stuff. "
     $log = Get-ChildItem $file |?{$_.LastWriteTime -ge (Get-Date).AddDays(-1)}
     }