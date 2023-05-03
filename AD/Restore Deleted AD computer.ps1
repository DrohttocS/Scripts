
#connect to SAEQDC01 to do the restore.
$prompt = "Nish\adm_"+"$env:USERNAME"

Invoke-Command -ComputerName saeqdc01 -Credential $prompt -ScriptBlock {
while($true){
# Ask the user to input the part of the computer name to search for
$computerNamePart = Read-Host "Enter a part of the computer name to search and restore. Enter Q to quit."
$computerNamePart = "*$computerNamePart*"
if($computerNamePart -eq '*Q*'){
        break
    }
Try{
# Search for the deleted computer object
$deletedComputer = Get-ADObject -Filter {cn -like $computerNamePart -and isDeleted -eq $true} -IncludeDeletedObjects -Properties lastknownParent

     $menu = @{}
        for ($i=1;$i -le $deletedComputer.count; $i++) {
            Write-Host "$i. $($deletedComputer[$i-1].name.substring(0,15))" -ForegroundColor Green
            $menu.Add($i,($deletedComputer[$i-1]))
        }
        [int]$ans = Read-Host 'Enter selection (or enter Q to quit)'
        if($ans -eq "Q"){
            break
        }
        $selection = $menu.Item($ans) 

if ($selection) {
    # Restore the computer object
    Restore-ADObject -Identity $selection.ObjectGUID -TargetPath $selection.lastKnownParent 

    # Search for associated objects
    $associatedObjects = Get-ADObject -Filter {isDeleted -eq $true -and lastKnownParent -eq $selection.DistinguishedName} -IncludeDeletedObjects

    # Restore associated objects
    foreach ($associatedObject in $associatedObjects) {
        Restore-ADObject -Identity $associatedObject.ObjectGUID -TargetPath $associatedObject.lastKnownParent 
    }

    Write-Host "Computer object and associated objects have been restored successfully." -ForegroundColor Green
} else {
    Write-Host "No computer object found matching the provided input." -ForegroundColor Red
}
}Catch{
 Write-Host "No computer object found." -ForegroundColor Red
}
}
}