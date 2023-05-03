<# 
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
# Creds 
$creds = Import-Credential -Path C:\Support\sacred.txt

#>

$DaysInactive = 30
$time = (Get-Date).Adddays(-($DaysInactive)) 
$RDPserver = Get-ADComputer -Filter {whenChanged -ge $time -and enabled -eq $true -and OperatingSystem -Like '*Server*' }  | sort name
$menu = @{}
for ($i=1;$i -le $RDPserver.count; $i++) {
    Write-Host "$i. $($RDPserver[$i-1].name)" -ForegroundColor Green
    $menu.Add($i,($RDPserver[$i-1].name))
    }

[int]$ans = Read-Host 'Enter selection'
$selection = $menu.Item($ans) 
mstsc /admin /v $selection 