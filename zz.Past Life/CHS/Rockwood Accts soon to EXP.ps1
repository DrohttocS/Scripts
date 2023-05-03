#Rockwood Pull / No Email Address
$MaxPassAge = (Get-QADObject (Get-QADRootDSE).defaultNamingContextDN).MaximumPasswordAge.days
$DaysToExpire = 7

#Pull Account Info from US Domain
$RWC = Get-QADUser -Enabled -PasswordNeverExpires:$false -SizeLimit 0 -SearchRoot US.chs.net/WA/Spokane1501/Users|`
       Select-Object Firstname,Lastname,Name,Email,@{Name="Expires";Expression={ $MaxPassAge - $_.PasswordAge.days }} |`
       Where-Object {$_.Expires -gt 0 -AND $_.Expires -le $DaysToExpire -and $_.email -eq $null} 

# Merge RWC mail info into user array
foreach($rwc_user in $RWC){
        $rwcDisplay = ($rwc_user.FirstName) + " " + ($rwc_user.LastName) +"*"
        $rwcEmail = Get-ADUser -Filter { displayName -like $rwcDisplay } -Properties mail | Select-Object mail
        $rwc_user.email = $rwcEmail.mail
   }
# Remove Accounts not found
$RWC_C = $RWC | where {$_.email -ne $null}
$RWC_C | ft