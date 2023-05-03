$userToTerminate = Read-Host "Please enter the username of the user that you would like to terminate (just username, do not include @domain.com)"
$date = Get-Date -UFormat %D
Function RemoveFromGroups
{
    try
    {
        Remove-ADPrincipalGroupMembership -Identity $userToTerminate -Confirm:$false -MemberOf $(Get-ADPrincipalGroupMembership -Identity $userToTerminate | Where-Object {$_.Name -ne  "Domain Users"}) 
    }
    catch
    {
    }
}
Function RemoveEmailPhone
{
    try
    {
        $user =  
         Get-ADUser $userToTerminate   | Set-ADUser -Clear mail,telephoneNumber,proxyAddresses  -Description "DISABLED - $Date by  $env:USERNAME" -enabled $false -PassThru  |`
         Move-ADObject  -TargetPath "OU=Disabled Users,DC=NISH,DC=ORG"
      Get-ADUser $userToTerminate -Properties Description,mail,telephoneNumber,proxyAddresses
    }
    catch
    {
        Write-Host "$userToTerminate is not in AD, or script is not functioning properly. READ the error message."
    }
}


RemoveFromGroups
RemoveEmailPhone