$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$ISECred = Get-StoredCredential -Target "$env:USERNAME-ise"
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort #| select -First 3

$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs

$res=@()
$res =
try{   
        
      $res =  Invoke-Command -Session $session -ScriptBlock {
        
            $dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort # | select -last 3
            $RA=@()
            $RA +=  Foreach($dc in $dcs){
                            $dc =  Get-ADDomainController -Server $DC 
                            $ping = Test-Connection -ComputerName $dc.name -Count 1 -BufferSize 1024  -ErrorAction SilentlyContinue
                  
                    New-Object PSObject -Property ([ordered]@{
                            Identity = $env:COMPUTERNAME
                            "Ping"   = $ping.Address
                            "Raw Speed" = $ping.ResponseTime
                            "Calc Speed" =[math]::Log10(1000-$ping.ResponseTime)*100
                            "Site"     = $dc.site
                            })
                            }
                  $RA

}

$res
}Catch{
    Write-Warning "Could not access $dc"
              New-Object PSObject -Property ([ordered]@{
                            Identity = $dc.name
                            "Ping"   = $ping.Address
                            "Raw Speed" = 'N/A'
                            "Calc Speed" ='N/A'
                            "Site"     = $dc.site
                            })
Continue
}


  Remove-PSSession $session
  