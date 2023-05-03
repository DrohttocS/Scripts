
# Inventory Automation
# Post Config / After Joining the domain and renaming the system 




$SeeDate = Get-Item C:\Users\Scott\Desktop\Scott.txt | select LastWriteTime
$SeeDate = $SeeDate.LastWriteTime.ToString('MM/dd/yyyy')
echo $SeeDate
