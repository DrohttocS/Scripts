$table = Import-csv -Path 'C:\temp\NPA Delete List.csv'
Function RemoveFromGroups
{
    try
    {
        Remove-ADPrincipalGroupMembership -Identity $userToTerminate -Confirm:$false -MemberOf $(Get-ADPrincipalGroupMembership -Identity $userToTerminate | Where-Object {$_.Name -ne  "Domain Users"}) 
    }
    catch
    {
        Write-Host "Script is not functioning properly or we need to double check the error message."
    }
}
Function RemoveEmailPhone
{
    try
    {
        $user =  
         Get-ADUser $userToTerminate   | Set-ADUser -Clear mail,telephoneNumber,proxyAddresses  -Description "DISABLED - $Date by  $env:USERNAME" -enabled $false -PassThru  |`
         Move-ADObject  -TargetPath "OU=_Disabled,OU=Extranet OU,DC=NISH,DC=ORG"
      Get-ADUser $userToTerminate -Properties Description,mail,telephoneNumber,proxyAddresses
    }
    catch
    {
        Write-Host "$userToTerminate is not in AD, or script is not functioning properly. READ the error message."
    }
}

foreach($line in $table){
$userToTerminate = $line."SAM Account Name".Trim()
RemoveFromGroups
RemoveEmailPhone
}