Get-ADUser -Identity * -Properties sAMAccountName,HomeDirectory |`
   Select sAMAccountName,HomeDirectory