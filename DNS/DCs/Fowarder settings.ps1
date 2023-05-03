

$NS = Resolve-DnsName -Name nidecds.com -Type NS | `
    Where {$_.Type -eq 'NS'} | `
    Select-Object -ExpandProperty NameHost

$output = 


foreach ($server in $NS) {

$fwd = Get-DnsServerForwarder -ComputerName $server
$fwdrs = $fwd | select -ExpandProperty IPAddress | select -ExpandProperty IPAddressToString

        New-Object PSObject -Property ([ordered]@{
                    Identity          = $server
                    'fwd'             = $fwdrs -join ","

                })

}
