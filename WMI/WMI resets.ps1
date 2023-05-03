$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


winmgmt /verifyrepository

winmgmt /salvagerepository

winmgmt /resetrepository