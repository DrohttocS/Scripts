$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort

$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs

$res = Invoke-Command -Session $session -ScriptBlock {
      $days =   (Get-Date) - ((Get-WmiObject win32_operatingsystem).ConvertToDateTime((Get-WmiObject win32_operatingsystem).lastbootuptime)) | select -ExpandProperty Days
      If($days -ge 30){
      Write-warning "Rebooting $env:COMPUTERNAME"        
      Restart-Computer -WhatIf}Else{Write-Host "Skipping $env:COMPUTERNAME"
      
}
$res

Remove-PSSession $session

