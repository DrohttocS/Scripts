New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-sftp"
$sftpcred = Get-StoredCredential -Target "$env:USERNAME-sftp"



$SFTPSession = New-SFTPSession -ComputerName sftpsupport-na.avantgardportal.com -Credential $sftpcred

Get-SFTPChildItem -SessionId $SFTPSession.SessionId 



  -Path $sourceTest | ForEach-Object{
    if ($_.Fullname -like '*.csv') 
    {  
        Get-SFTPFile $sessionTest -RemoteFile $_.FullName -LocalPath $destinationTest -Overwrite 
    }

    write-output $_.FullName 

}

