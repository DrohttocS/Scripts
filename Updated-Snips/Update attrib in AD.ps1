$adusers = Get-aduser -filter * -Properties * | select givenname, sn, telephonenumber, ipphone,emailaddress
$csv = Get-Content C:\Users\shord2126\Downloads\PhoneEXT.csv  | ConvertFrom-CSV -Header FirstName,LastName,EmailAddress,MobileNumber,AuthPassword,AuthID,IPPhone,EXT,DID,PIN,OutboundCallerID,MAC_0,InterfaceIP_0,DeskphoneWebPass,SrvcAccessPwd,PhoneModel14,PhoneTemplate14


Get-ADUser -Filter * -Properties * |  Select-Object -ExpandProperty msExchShadowProxyAddresses



$users= "KWerk7415","cturm4651","kping0509","ssmit4680","cathy.bradysorenson","katie.peters","Shannon.Vojta","Patsy.Anderson","RLeese","dlinhart"
foreach ($c in $users){
Get-ADUser -SearchBase "OU=Kalispell,OU=Family of Banks Users,DC=bvb,DC=local" -Properties * -Filter * | select name, proxyAddresses

}




$csv = Get-ADUser -SearchBase "OU=Kalispell,OU=Family of Banks Users,DC=bvb,DC=local" -Properties * -Filter *| Select name, extensionAttribute1
ForEach ($User in $csv){
   $Filter = $user.SamAccountName

   

     $userInstance = Get-ADUser $Filter -Properties *
    
     $userInstance.extensionAttribute1 = "Kalispell"
   
     #$userInstance.telephonenumber = $User.TelephoneNumber
    
     Write-Host Setting $user 
    Set-ADUser -Instance $userInstance
     Get-ADUser  -Properties *  
     }


