$TSMcList = gc C:\Users\scohor\Documents\CHS\BackupList.txt | sort
$TSMcList= $TSMcList -replace "_TDP"
$ErrorActionPreference= 'silentlycontinue'
$RHS = @()
foreach ($client in $TSMcList) {
$RHS += Resolve-DnsName -Name $client
}
$rwc = $RHS | Where-Object { $_.name -like "*.rwc.com"} | Select-Object Name
$chs = $RHS | Where-Object { $_.name -like "*.Local"} | Select-Object Name


# Restart RWC Services
foreach($serv in $rwc){
    If (Test-Connection -ComputerName $serv -count 1 -quiet) {
        Get-Service -name 'TSM *' -computername $serv  | Set-Service -Status Running
        "$serv TSM Client is running"
      }
    Else {
      "$serv is offline. Ditch that Bugger. It's slowing stuff down!" 
      #$deadServers += $serv | Out-GridView
      }  
    }
# Restart CHS TSM Services 
$dc = Test-Path -Path CHS:
if(!($dc)){
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


$cred = Import-Credential -Path C:\admin\CHS_SecureString.txt
New-PSDrive `
    –Name CHS `
    –PSProvider ActiveDirectory `
    –Server "chsspokane.local" `
    –Credential $cred  `
    –Root "//RootDSE/" `
    -Scope Global

    
}


ts
    foreach($serv in $chs){
    If (Test-Connection -comp $serv -count 1 -quiet) {
        Get-Service -name 'TSM *' -computername $serv  | Set-Service -Status Running
        "$serv TSM Client is running"
      }
    Else {
      "$serv is offline. Ditch that Bugger. It's slowing stuff down!" 
       $deadServers += $serv | Out-GridView
      }  
    }