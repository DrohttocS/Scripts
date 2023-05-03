$Computers = get-content "C:\Admin\Corp\enc\ad.txt"
$OutFile = "C:\users\scohor\Desktop\Results.txt"

# $c$\Program Files\Symantec\Symantec Endpoint Encryption Clients\TechLogs\GEFdeTcgOpal.log

#Erase an existing output file so as not to duplicate data
out-file -filepath $OutFile

foreach ($Computer in $Computers)
{
    
if (test-path "\\$computer\c$\Program Files\Symantec\Symantec Endpoint Encryption Clients\TechLogs\GEFdeTcgOpal.log")  #test to make sure the file exists
    {
    #Get the CreationTime value from the file
    $FileDate = (Get-ChildItem "\\$computer\c$\Program Files\Symantec\Symantec Endpoint Encryption Clients\TechLogs\GEFdeTcgOpal.log").CreationTime

    #Write the computer name and File date separated by a unique character you can open in Excel easy with"
    "$Computer | $FileDate" | out-file -FilePath $OutFile -Append
    }
    else
    {
    #File did not exist, write that to the log also
    "$Computer | FILE NOT FOUND" | out-file -FilePath $OutFile -Append 
    }
}