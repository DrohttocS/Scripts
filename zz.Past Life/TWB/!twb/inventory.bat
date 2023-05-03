set Model=0
set mm=%date:~4,2%
set dd=%date:~7,2%
set yyyy=%date:~10,4%

for /f "tokens=2 delims==" %%f in ('wmic bios get serialnumber /value ^| find "="') do set "SerialNumber=%%f"
for /f "tokens=2 delims==" %%f in ('wmic bios get smbiosbiosversion /value ^| find "="') do set "BiosVer=%%f"
for /f "tokens=2 delims==" %%f in ('wmic ComputerSystem Get Model /value ^| find "="') do set "Model=%%f"
for /f "tokens=3 delims=\=" %%f in ('wmic ComputerSystem Get username /value ^| find "\"') do set "Tech=%%f"
for /F "tokens=2 delims=\=" %%f in ('wmic computersystem get username /value') do set "Entity=%%f"

for %%a in ("C:\Program Files\Symantec\Symantec Endpoint Encryption Clients\TechLogs\GEFdeTcgOpal.log") do set FileDate=%%~ta

set compname=%computername%


echo "%computername% - Updated to Teller16" >> "c:\support\%computername%-Updated to Teller16.txt"


