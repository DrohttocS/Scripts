Add-PSSnapin Quest.ActiveRoles.ADManagement
# Free to download http://www.quest.com/powershell/activeroles-server.aspx  
# 
# Original Script by Sean Kearney 
# http://gallery.technet.microsoft.com/scriptcenter/83d39949-3e22-45ef-aaba-3a4e17341c5e 
#  
# List all users in that have not logged on within  
# XXX days in "Active Directory"  
#
# AND password has not been changed for
#   
# Get the Current Date  
$COMPAREDATE=GET-DATE  
#  
# Number of Days to check back (user must not have logged in for this many days)     
$NumberDays=89  
#
#Password Age (password must at least this many days old)
$PasswordAgeDays=91
#  
# Organizational Unit to search  
#$OU='OU=Disabled,DC=CHSspokane,DC=local'
$OU='rwc.com/Disabled Accounts'
#$OU='CHSspokane.local/Disabled Users'
#
#Get-ADUser -Filter {(ObjectClass -eq "user")} -SearchBase $OU | Set-ADUser -PasswordNeverExpires:$FALSE
#  
# Find users in OU above that are not disabled, password has not changed for # of days specified
GET-QADUSER -SizeLimit 0 -Disabled:$True –PasswordNotChangedFor $PasswordAgeDays -SearchRoot $OU |  

#And user has not logged in for at least # of days specified
where { $_.lastlogontimestamp -le (get-date).adddays(-$NumberDays) } |  


#Uncomment This to acutally disable user
 #DISABLE-QADUSER |  select Name, ParentContainer, Department, Office, Description, LastLogonTimeStamp, LastLogon, AccountIsDisabled, PasswordExpires, PasswordLastSet, PasswordNeverExpires | out-gridview #Export-Csv C:\admin\disable_accounts_password_age_greater_91_days_$date.csv -noTypeInformation 

# Delete User
 # remove-QADObject 


