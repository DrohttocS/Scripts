@ECHO OFF
Color 0A
Prompt $G $S


:MENU
CLS
ECHO.
ECHO.
ECHO ================ TRAILWEST BANK APPLICATION INSTALLATION =================
ECHO.
ECHO  1.  Reset OneNote 
ECHO         This will remove all Notebooks. 
ECHO         Remap them by choosing the appropriate option below.
ECHO.
ECHO  2.  Add Compliance Notebooks
ECHO  3.  Add Customer Service Notebooks
ECHO  4.  Add Deposit Account Analysis notebooks
ECHO  5.  Add Loans Notebooks
ECHO  6.  Add Real Estate Notbooks
ECHO  7.  Add Marketing Notebooks
ECHO  8.  Add Tech Projects Notebooks (IT ONLY)
ECHO  9.  Add Management Notebooks
ECHO  10. Add Operations Committee
ECHO.
ECHO ====================== PRESS 'Q' TO QUIT ===============================
ECHO.

SET INPUT=
SET /P "INPUT=Please select a number: "
IF /I '%INPUT%'=='1' GOTO Reset_Onenote
IF /I '%INPUT%'=='2' GOTO Compliance_Notebooks
IF /I '%INPUT%'=='3' GOTO Customer_Service_Notebooks
IF /I '%INPUT%'=='4' GOTO Deposit_Account_Analysis_notebooks
IF /I '%INPUT%'=='5' GOTO Loans_Notebooks
IF /I '%INPUT%'=='6' GOTO RE_Notebooks
IF /I '%INPUT%'=='7' GOTO Marketing_Notebooks
IF /I '%INPUT%'=='8' GOTO Tech_Projects_Notebooks
IF /I '%INPUT%'=='9' GOTO Management_Notebooks
IF /I '%INPUT%'=='10' GOTO Operations_Committee
IF /I '%INPUT%'=='Q' GOTO EOF
CLS

ECHO =========== INVALID INPUT ============
ECHO -------------------------------------
ECHO Please select a number from the Main
echo Menu or select 'Q' to quit.
ECHO -------------------------------------
ECHO ======= PRESS ANY KEY TO CONTINUE ====

PAUSE > NUL
taskkill /f /im onenote.exe
GOTO MENU

:Reset_Onenote
taskkill /f /im onenote.exe
echo Clearing cache
rmdir /s/q "C:\Users\%Username%\AppData\Local\Microsoft\OneNote\16.0\cache"
rmdir /s/q "C:\Users\%Username%\AppData\Local\Microsoft\OneNote\14.0\cache"
reg delete  HKEY_CURRENT_USER\Software\Microsoft\Office\14.0\OneNote\OpenNotebooks /va /f
reg delete  HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\OneNote\OpenNotebooks /va /f
GOTO MENU

:Compliance_Notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Compliance\BSA Software Evaluation\Open Notebook.onetoc2"
	"V:\Compliance\CC Vendor Switch Evaluation\Open Notebook.onetoc2"
	"V:\Compliance\Compliance Committee\Open Notebook.onetoc2"
	"V:\Compliance\CPI Card Group DD\Open Notebook.onetoc2"
	"V:\Compliance\ESIGN Evaluation\ESIGN Evaluation\Open Notebook.onetoc2"
	"V:\Compliance\Online Training Vendor Eval\Open Notebook.onetoc2"

GOTO MENU

:Customer_Service_Notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Customer Service\Bank Forms\Open Notebook.onetoc2"
	"V:\Customer Service\Debit Card Notebook\Open Notebook.onetoc2"
	"V:\Customer Service\HSA Health Savings Accounts\HSA  Health Savings Account\Open Notebook.onetoc2"
	"V:\Customer Service\IRA Individual Retirement Account\IRA Individual Retirement Account\Open Notebook.onetoc2"
	"V:\Customer Service\New Account\Open Notebook.onetoc2"
	"V:\Customer Service\Notary Info\Open Notebook.onetoc2"
	"V:\Customer Service\Online Banking Notebook\Open Notebook.onetoc2"
	"V:\Customer Service\Safe Deposit Box\Open Notebook.onetoc2"
	"V:\Customer Service\Teller\Open Notebook.onetoc2"
	"V:\Customer Service\Teller & CSR Meetings\Open Notebook.onetoc2"
	"V:\Customer Service\Teller & CSR Meetings\Teller CSR Archive\Open Notebook.onetoc2"
	"V:\Customer Service\Wire Tranfer Form & Info Notebook\Open Notebook.onetoc2"
	"V:\Customer Service\XD Cardinal\Open Notebook.onetoc2"

GOTO MENU

:Deposit_Account_Analysis_notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Deposit Account Analysis\Open Notebook.onetoc2"
	"V:\Deposit Account Analysis\Consumer DDA Analysis\Open Notebook.onetoc2"
	"V:\Digital Branch\Open Notebook.onetoc2"

GOTO MENU

:Loans_Notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Loans\Adverse Actions\Open Notebook.onetoc2"
	"V:\Loans\E-Sign\Open Notebook.onetoc2"
	"V:\Loans\HMDA Procedures & Training\Open Notebook.onetoc2"
	"V:\Loans\Real Estate Loan Processing\Open Notebook.onetoc2"
	"V:\Loans\Real Estate Loan Processing - Closings\Closing Checklists\Open Notebook.onetoc2"
	"V:\Loans\ReceiveThisFile Instructions\Open Notebook.onetoc2"

GOTO MENU


:Management_Notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Management\ALCO and Executive\Open Notebook.onetoc2"
	"V:\Management\BHC and Loan Committee\Open Notebook.onetoc2"
	"V:\Management\Cook Security ITM Evaluation\Open Notebook.onetoc2"
	"V:\Management\Shareholder letter\Shareholder letter\Open Notebook.onetoc2"

GOTO MENU

:Marketing_Notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Marketing\Credit Cards\Open Notebook.onetoc2"
	"V:\Marketing\Marketing Committee Notebook\Open Notebook.onetoc2"
	"V:\Marketing\Marketing Committee Notebook\Marketing Archive\Open Notebook.onetoc2"

GOTO MENU

:Operations_Committee
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Operations Committee\Open Notebook.onetoc2"

GOTO MENU

:Tech_Projects_Notebooks
tasklist|find /i "onenote.exe" >NUL
if errorlevel 1  (start onenote.exe)
	"V:\Tech Projects\1st Sec Deer Lodge Project\First Security Deer Lodge Core Project\Open Notebook.onetoc2"
	"V:\Tech Projects\Applications\Open Notebook.onetoc2"
	"V:\Tech Projects\Applications\Applications\Open Notebook.onetoc2"
	"V:\Tech Projects\Compliance 1 Mtg. Eval\Open Notebook.onetoc2"
	"V:\Tech Projects\DLP Vendor Evaluation\Open Notebook.onetoc2"
	"V:\Tech Projects\FDIC Exam 2018 Follow-Up\Open Notebook.onetoc2"
	"V:\Tech Projects\Internet\OnlineBanking\Open Notebook.onetoc2"
	"V:\Tech Projects\IT Security\Open Notebook.onetoc2"
	"V:\Tech Projects\Network\Network\Open Notebook.onetoc2"
	"V:\Tech Projects\Projects\Open Notebook.onetoc2"
	"V:\Tech Projects\Projects\First Call Projects\Open Notebook.onetoc2"
	"V:\Tech Projects\Projects\First Call Projects\New Section Group\Open Notebook.onetoc2"
	"V:\Tech Projects\Secure File Sharing Evaluation\Open Notebook.onetoc2"
	"V:\Tech Projects\Servers\Open Notebook.onetoc2"

GOTO MENU

:EOF
echo.
echo Thanks and have a nice day....
echo.    
echo.
timeout /t 30
