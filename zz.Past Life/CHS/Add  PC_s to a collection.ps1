#Set path to collection directory
$collectiondir = "C:\Users\scohor\Desktop\collection\"

#Pull only .TXT files into array
$filenames = @(Get-ChildItem $collectiondir* -include *.txt -Name)

for ($x=0; $x -lt ($filenames.Length); $x++) {
$collectionname = $filenames[$x].Split(".")[0]
$collectionname
#Add new collection based on the file name
try {
New-CMDeviceCollection -Name $collectionname -LimitingCollectionName "All Systems"
}
catch {
"Error creating collection - collection may already exist: $collectionname" | Out-File "$collectiondir\$collectionname`_invalid.log" -Append
}

#Read list of computers from the text file
$filename = $filenames[$x]
$computers = Get-Content $collectiondir$filename
foreach($computer in $computers) {
try {
Add-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionname -ResourceId $(get-cmdevice -Name $computer).ResourceID
}
catch {
"Invalid client or direct membership rule may already exist: $computer" | Out-File "$collectiondir\$collectionname`_invalid.log" -Append
}
}
}