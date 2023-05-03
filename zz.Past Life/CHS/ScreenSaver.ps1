
if (!(get-psdrive hkcr -ea 0)){New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | out-null}
if (!(get-psdrive hku -ea 0)){New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | out-null}


$regkeypath1 = "HKU:\.DEFAULT\Control Panel\Desktop"
$regkeypath2 = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $regkeypath1 -Name "ScreenSaveActive" -Value 1
Set-ItemProperty -Path $regkeypath2 -Name "ScreenSaveActive" -Value 1
Set-ItemProperty -Path $regkeypath1 -Name "ScreenSaverIsSecure" -Value 1
Set-ItemProperty -Path $regkeypath2 -Name "ScreenSaverIsSecure" -Value 1
Set-ItemProperty -Path $regkeypath1 -Name "SCRNSAVE.EXE" -Value c:\windows\policy\RHS.scr
Set-ItemProperty -Path $regkeypath2 -Name "SCRNSAVE.EXE" -Value c:\windows\policy\RHS.scr
#  Set Standard Desktop -Logon Screen Saver Timeout Time – in seconds
Set-ItemProperty -Path $regkeypath1 -Name "ScreenSaveTimeout" -Value 300
Set-ItemProperty -Path $regkeypath2 -Name "ScreenSaveTimeout" -Value 300