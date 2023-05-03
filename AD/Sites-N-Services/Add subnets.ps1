 #  Install-Module -Name CredentialManager
 #  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
 $AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
 
 $dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
 cls




$res = foreach($DCName in $dcs){

try{
        # NETLOGON.LOG path for the current Domain Controller
$path = "\\$DCName\admin`$\debug\netlogon.log"

# Testing the $path
IF ((Test-Path -Path $path ) -and ((Get-Item -Path $path ).Length -ne $null))
{
    IF ((Get-Content -Path $path  | Measure-Object -Line).lines -gt 0){
        #Copy the NETLOGON.log locally for the current DC
        Write-Verbose -Message "$DCName - NETLOGON.LOG - Copying..."
        Copy-Item -Path $path -Destination $ScriptPathOutput\$($dc.Name)-$DateFormat-netlogon.log 
        
        #Export the $LogsLines last lines of the NETLOGON.log and send it to a file
        ((Get-Content -Path $ScriptPathOutput\$DCName-$DateFormat-netlogon.log -ErrorAction Continue)[$LogsLines .. -1]) | 
            Out-File -FilePath "$ScriptPathOutput\$DCName.txt" -ErrorAction 'Continue' -ErrorVariable ErrorOutFileNetLogon
        Write-Verbose -Message "$DCName - NETLOGON.LOG - Copied"
    }#IF
    ELSE {Write-Verbose -Message "File Empty"}
}ELSE{Write-Warning -Message "$DCName NETLOGON.log is not reachable"}
}

Catch{
       Write-Warning "Could not access $DCName"
      


Continue
}
}


