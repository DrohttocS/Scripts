$props = "SAMAccountName","Name","PasswordNeverExpires","Enabled","LockedOut","PasswordLastSet","LastLogOnDate","CanonicalName","lastlogontimestamp,"
$results = Get-ADUser -Filter * -Properties $props -SearchBase "DC=bvb,DC=local" | Select $props | Out-GridView #Export-Csv -Path "C:\Users\scohor\Desktop\Disabled RWC accounts.csv" -NoTypeInformation



Set-ADUser -Identity GlenJohn -Remove @{otherMailbox="glen.john"} -Add @{url="fabrikam.com"} -Replace @{title="manager"} -Clear ProfilePath


Get-ADUser -Filter {Enabled -eq $True -and ProfilePath -ne "$Null" } -Property profilepath  | % {Set-ADUser $_  -Clear ProfilePath}


Get-ADUser -Filter {HomeDrive -ne "$Null" -and enabled -eq $true} -Property * |select Name,HomeDirectory,HomeDrive | ft -AutoSize -Wrap


