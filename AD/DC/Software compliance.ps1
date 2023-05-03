$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$ISECred = Get-StoredCredential -Target "$env:USERNAME-ise"
$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$session = New-PSSession  -ComputerName $dcs -EnableNetworkAccess -Credential $AdminCred


$res = Invoke-Command -Session $session -ScriptBlock{
    $Installed = Get-CimInstance -ClassName win32_product | select name -ExpandProperty name
        $cs = $Installed -contains "CrowdStrike Sensor Platform" 
        $Duo = $Installed -contains "Duo Authentication for Windows Logon x64"
        $Rapid7 = $Installed -contains "Rapid7 Insight Agent"
        $land = $Installed -contains "LANDESK Advance Agent"

        New-Object PSObject -Property ([ordered]@{
            Identity          = $ENV:COMPUTERNAME
            'Crowd Strike' = $cs
            'Duo Authentication' = $Duo
            "Rapid7 Insight Agent" = $Rapid7
            "LANDESK Advance Agent" = $land

        })

        }

        
Remove-PSSession $session
$res| Out-GridHtml
