# Gets time stamps for all computers in the domain that have NOT logged in since after specified date 
import-module activedirectory  
$domain = "bvb.local"  
$DaysInactive = 90  
$time = (Get-Date).Adddays(-($DaysInactive)) 
  $date = (Get-Date).Adddays(-($DaysInactive))
# Get all AD computers with lastLogonTimestamp less than our time 

Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | select name,passwordlastset
  

get-adcomputer -filter {passwordlastset -lt $date} -properties passwordlastset | remove-adobject -recursive -verbose -confirm:$true
