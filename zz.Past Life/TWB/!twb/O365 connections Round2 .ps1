function Import-Credential 
{
   param
   (
     [Parameter(Mandatory=$true)]
     $Path
   )
    
  $CredentialCopy = Import-Clixml $path    
  $CredentialCopy.password = $CredentialCopy.Password | ConvertTo-SecureString    
  New-Object system.Management.Automation.PSCredential($CredentialCopy.username, $CredentialCopy.password)
}

$mailcreds = Import-Credential -Path "C:\Support\AdminCredo365.txt"

#Open a session to O365
$ExOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $mailcreds -Authentication  Basic -AllowRedirection
import-PSSession $ExOSession -AllowClobber


#doing some stuff

$DistroLists = Get-DistributionGroup -ResultSize Unlimited

#Run message trace on each Distribution List to see if it recieved mail in the past x days.
$DistroListsInUse = $DistroLists | select -ExpandProperty primarysmtpaddress  | Foreach-Object { Get-MessageTrace -RecipientAddress $_ -Status expanded -startdate (Get-Date).AddDays(-10) -EndDate (Get-Date) -pagesize 1| select -first 1} 

$DistroListsInUse.RecipientAddress.Count






# done with stuff
Remove-PSSession $ExOSession