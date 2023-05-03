# $dcs = (Get-ADForest -Server AMRNDSVPDC03).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$dcs = "AKRUSNDSVPDC01", "AMRNDSVPDC01", "AMRNDSVPDC03", "AMRNDSVPDC04", "AMRNDSVPDC06", "AMRNDSVPDC07", "ASHUSEQXVPDC01", "CANUSNDSVPDC01", "CASITANDSVPDC01", "CMDMXNDSVPDC01", "CNGUAPINFDC03", "CORUSNDSVPDC01", "CZOMCPINFDC02", "DALUSEQXVPDC01", "DEFRAPINFDC01", "DEHENPINFDC02", "DESALPINFDC02", "EGVUSNDSVPDC01", "EMANDSVPDC02", "FRACOPINFDC02", "FRANGPINFDC03", "FRANGPINFDC04", "FRCEBPINFDC02", "FRSSOPINFDC02", "FZUCNNDSVPDC01", "GBANDPINFDC02", "GBU79PINFDC01", "GLEUSNDSVPDC01", "HUIMIPINFDC02", "INBNGPINFDC02", "INPUSNDSVPDC01",  "KDM2MXNDSVPDC01", "LEXUSNDSVPDC01", "LIVUSNDSVPDC01", "MANPHNDSVPDC01", "MARCANDSVPDC01", "MENUSNDSVPDC01", "MIDUSNDSVPDC01", "MKTUSNDSVPDC01", "MONMXMILVPDC01", "MXREYPINFDC01", "NLAMXNDSVPDC01", "PARUSNDSVPDC01", "PLPZNPINFDC02", "PRNUSNDSVPDC02", "QNGCNNDSVPDC01", "RANUSNDSVPDC01", "REY2MXNDSVPDC01", "REYMXNDSVPDC02", "SGSPRPINFDC02", "SHDCNNDSVPDC01", "SHVUSNDSVPDC01", "SLPMXNDSVPDC01", "STLUSNDSVPDC02", "SYRUSNDSVPDC01"

cls
$HostToPing = Read-Host "Who are we looking up (FQDN)"



$res = foreach ($dc in $dcs)
{
	try
	{
		$dsq = Resolve-DnsName -Name $HostToPing -Server $dc -ErrorAction Stop
		New-Object PSObject -Property ([ordered]@{
				Identity = $dc
				"Name"   = $dsq.Name.Split('.', 2)[0]
				"IP"	 = $dsq.IP4Address
			})
		
	}
	Catch
	{
		Write-Warning "Could not RESOLVE on $dc"
		New-Object PSObject -Property ([ordered]@{
				Identity = $dc
				"Name"   = 'N/A'
				"IP"	 = 'N/A'
			})
		
		Continue
	}
}


$bad = $res | ? { $_.name -EQ 'N/A' } | select -ExpandProperty Identity
$badCount = $bad.Count
$tDCS = $dcs.count
$dccount = $tDCS - $badCount

Write-Host "`n Checking $HostToPing's Name resolution on $dccount out of $tDCS dc's.`n $badCount DC(s) did not respond to the dns name query."
$res | group IP | select count, name
