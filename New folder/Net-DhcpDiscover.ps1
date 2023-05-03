# Gets time stamps for all computers in the domain that have NOT logged in since after specified date 
# Mod by Tilo 2013-08-27 
import-module activedirectory  
$domain = "bvb.local"  
$DaysInactive = 128  
$time = (Get-Date).Adddays(-($DaysInactive)) 
  
# Get all AD computers with lastLogonTimestamp less than our time 
$dead = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp  |
  
# Output hostname and lastLogonTimestamp into CSV 
select-object Name 