@echo off

md "c:\Support\T16\"
pushd "\\bvbdc4.bvb.local\Data\General\OPERATIONS\Cardinal\!Teller16.1.3Upgrade"

echo Copying Files to your local machine
xcopy Teller*.exe "c:\Support\T16\"
cd "c:\Support\T16\"
echo Extracting dB ..... 
start /wait TellerFullDB030118.exe

ren "TellerFullDB030118.bak" "c:\Support\T16\teller.bak"
pause
echo Launching Teller 16 installation
echo This will take a minute, Go grab a cup of coffee
start /wait Teller_16.01.03.exe -s
pause
echo Teller 16 should now be installed
echo Time to Replace database
Pause
echo until I get this piece scripted open another admin cmd prompt
echo and past the following.
echo.
 sqlcmd /S localhost\cardinalplatform /U cardinal /P cArDiNaL_12345$$
 restore database teller from disk='C:\Support\T16\teller.bak' with replace
 go
echo exit
echo.
echo takes about 3 mins run...
pause
sc stop MSSQL$CARDINALPLATFORM
ping -n 15 127.0.0.1
sc start MSSQL$CARDINALPLATFORM
pause
echo Ok time to Test ... 

