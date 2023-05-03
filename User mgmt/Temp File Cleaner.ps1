echo "
Removing Temp items from...

"
$ErrorActionPreference= 'silentlycontinue'
rem to add more locations just append it to the $tempfolders var
$tempfolders = @( "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*","c:\temp\*" )
echo $tempfolders
Remove-Item $tempfolders -force -recurse
echo "
Ok, all clean.
"
