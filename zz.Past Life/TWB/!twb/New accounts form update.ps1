
# Copy zip from local PC to Target PC
$bon = New-PSSession  -ComputerName "MBW-TLR02-0116"
Copy-Item "C:\Support\NewAccts\New Accounts.zip"  -Destination "C:\Cardinal" -ToSession $bon -Force
Get-PSSession | Remove-PSSession


# Extract file on target pc and move up a folder
Enter-PSSession -Credential $AdminCred -ComputerName "HAM-CSR1-0120"
Get-Process msa*
cd C:\Cardinal
Expand-Archive '.\New Accounts.zip' -DestinationPath C:\Cardinal\
$dir = 'C:\Cardinal\New Accounts Form Update'
Set-Location $dir
$files = Get-ChildItem .
Foreach ($file in $files)
{
	Try
	{
		Move-Item -Path $file -Destination "..\" -Force
	}
	Catch
	{
		Move-Item -Path $file -Destination "..\_$file" -Force
	}
}

Set-Location ..\
dir
Remove-Item $dir
Remove-Item 'C:\Cardinal\New Accounts.zip'

gci -Path C:\Cardinal
Exit-PSSession