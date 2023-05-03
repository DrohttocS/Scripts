Import-Module activeDirectory
$csv = Get-Content "C:\Users\shord2126\Downloads\extensions (2).csv" | ConvertFrom-CSV -Header IPPhone,FirstName,LastName,EmailAddress,MobileNumber,AuthID,AuthPassword,WebMeetingFriendlyName,WebMeetingPrivateRoom,ClickToCall,WebMeetingAcceptReject,EnableVoicemail,VMNoPin,VMPlayCallerID,PIN,VMPlayMsgDateTime,VMEmailOptions,QueueStatus,OutboundCallerID,SIPID,DeliverAudio,SupportReinvite,SupportReplaces,EnableSRTP,ManagementAccess,ReporterAccess,WallboardAccess,TurnOffMyPhone,HideFWrules,CanSeeRecordings,CanDeleteRecordings,RecordCalls,CallScreening,EmailMissedCalls,Disabled,DisableExternalCalls,AllowLanOnly,BlockRemoteTunnel,PinProtect,MAC_0,InterfaceIP_0,UseTunnel,DND,UseCTI,StartupScreen,HotelModuleAccess,DontShowExtInPHBK,DeskphoneWebPass,SrvcAccessPwd,VoipAdmin,SysAdmin,SecureSIP,PhoneModel14,PhoneTemplate14,CustomTemplate,PhoneSettings,AllowAllRecordings,PushExtension,Integration
ForEach ($User in $csv){
   $Filter = "givenName -like ""*$($User.FirstName)*"" -and sn -like ""$($User.LastName)"""

    Get-ADUser -Filter $Filter -Properties * | Select name,ipphone,telephonenumber #|Where ipphone -eq ""| ft 

     $userInstance = Get-ADUser -Filter $Filter -Properties *
    
     $userInstance.ipphone = $User.IPPhone
   
     #$userInstance.telephonenumber = $User.TelephoneNumber
    
     Write-Host Setting $user 
    Set-ADUser -Instance $userInstance 
      
       
}

