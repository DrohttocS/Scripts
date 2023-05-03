# This PowerShell Command will query Active Directory and return the computer accounts which have not logged for the past
# 60 days.  You can easily change the number of days from 60 to any number of your choosing.  lastLogonDate is a Human
# Readable conversion of the lastLogonTimeStamp 

$then = (Get-Date).AddDays(-60) # The 60 is the number of days from today since the last logon.

Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $then} | FT Name,lastLogonDate

# If you would like to Disable these computer accounts, uncomment the following line:
# Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $then} | Set-ADComputer -Enabled $false

# If you would like to Remove these computer accounts, uncomment the following line:
# Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $then} | Remove-ADComputer