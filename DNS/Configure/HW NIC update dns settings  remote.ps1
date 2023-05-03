$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Enter-PSSession -ComputerName  manphndsvpdc01 -Credential $AdminCred


Get-NetAdapter | %{ Set-DnsClientServerAddress -InterfaceAlias $_.ifAlias -ServerAddresses ("10.142.80.32", "10.112.10.99") }

Exit-PSSession