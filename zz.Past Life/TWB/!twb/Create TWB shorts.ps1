# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

$scPath=@()
$scpath = "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\ShortCuts\"
If(!(test-path $scpath))
{
      New-Item -ItemType Directory -Force -Path $scpath
}



$WshShell = New-Object -comObject WScript.Shell
$path = 
$targetpath = "https://WEBSITE.com"
$iconlocation = "C:\Users\USER\Desktop\YourIcon.ico"
$iconfile = "IconFile=" + $iconlocation
$Shortcut = $WshShell.CreateShortcut($path)
$Shortcut.TargetPath = $targetpath
$Shortcut.Save()
Add-Content $path "HotKey=0"
Add-Content $path "$iconfile"
Add-Content $path "IconIndex=0"