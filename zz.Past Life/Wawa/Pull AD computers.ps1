

 Get-ADComputer -Filter {OperatingSystem -notlike '*10*' -and OperatingSystem -notlike '*XP*' -and OperatingSystem -notlike 'netapp*' -and OperatingSystem -notlike 'Pulse*' -and  OperatingSystem -notlike '*11*' -and OperatingSystem -notlike '*7*' -and  OperatingSystem -notlike "Mac*" -and OperatingSystem -notlike "*unknown*"}  -Properties CanonicalName,OperatingSystem,LastLogonDate | Select CanonicalName,DNSHostName,Enabled,OperatingSystem,Name,LastLogonDate| Out-GridHtml  -FilePath c:\temp\adc.htm

