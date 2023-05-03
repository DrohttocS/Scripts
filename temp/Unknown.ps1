#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"

Invoke-Command -ComputerName AMRNDSVPAP16 -ScriptBlock {get-localuser -name "*" | select Username}
$1dc = $dcs | select -First 1

foreach ($PC in $dcs) {
    if (Test-Connection $PC -Count 1) {
        Invoke-Command -ComputerName $PC -Credential $AdminCred -ScriptBlock {
            $user = get-localuser "*"
            if ($user) {
                [PSCustomObject]@{
                    Name         = $user
                    Computername = $pc
                }
            }

        }
    }
}



$res = foreach($pc in $1dc){

try{
         
       Invoke-Command -ComputerName $PC -Credential $AdminCred -ScriptBlock {
            $user = get-localuser "*"
            New-Object PSObject -Property ([ordered]@{

                    Name         = $user.name | Out-String
                    Computername = $env:COMPUTERNAME
                })
            

        }


}
Catch{
       Write-Warning "Could not access $PC"
       New-Object PSObject -Property ([ordered]@{
                    Name         = n/A
                    Computername = $PC
            })
    
Continue
}
}
$res

N1d3c2017!