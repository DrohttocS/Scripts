<#
.SYNOPSIS
Script that will verify 'A' and 'PTR' Records Relationship by querying the DNS server
.DESCRIPTION
This script will check and verify the Forward 'A' record(s) and it's associated 'PTR' record(s) by querying the DNS server.
This script can be run either on a DNS server locally or on a client machine that can query to a DNS server, in which case you need 
to specify the hostname list, dns server IP address and domain suffix (optional).
If no parameter is specified, then the script will check if the DNS server service is running and enumerate all 'A' records  and verify associated 'PTR' records.
The script ignores the automatically created DNS zones when enumerating 'A' records.
The explanation of each column output is as below >>
FQDN => The fully qualified domain name of 'A' records.
IPAddress => The IP address(es) result from Forward 'A' lookup.
Fstatus => The forward query status. If the 'A' record is found, then it is set as 'OK'.
FFound (ForwardFound) => 'Found' if the forward record is found and resolvable, 'Not Found' if the the 'A' record is not found.
RFound (ReverseFound) => 'Found' if any PTR record associated with the 'A' record is found. 'Not Found' if there is no PTR record for the given 'A' record.
RStatus => The status that is resulted from the 'ReverseNameMatched' and 'PTRNameHostResolveBack' value. 
		If both values are 'Matched' then, it's 'OK'.
		If 'ReverseNameMatched' is 'Partially Matched' and 'PTRNameHostResolveBack' is 'Matched' then, it's 'OK'.
		If 'ReverseNameMatched' is 'Partially Matched' and 'PTRNameHostResolveBack' is 'Partially Matched' then, it's 'Not OK'.
		If 'ReverseNameMatched' is 'Not Matched' and 'PTRNameHostResolveBack' is 'Partially Matched' then, it's 'Not OK'.
		If 'ReverseNameMatched' is blank (PTR not found) and 'PTRNameHostResolveBack' is 'Not  Matched' then, it's 'Not OK'.
ReverseNameMatched => If the NameHost(s) of the PTR record (result from  the PTR lookup) matches the FQDN, then 'Matched'.
			If the any of the NameHost(s) of the PTR record, matches the FQDN, then 'Partially Matched'.
			If the none of the NameHost(s) of the PTR record, matches the FQDN, then 'Partially Matched'.
PTRNameHostResolveBack => If the IP Address(es) from the Forward Lookup of the PTR's NameHost matches the FQDN's IP address(es), then 'Matched'.
				If any of the IP Addresseses from the Forward Lookup of the PTR's NameHost matches the FQDN's IP address(es), then 'Partially Matched'.
				If none of the IP Addresseses from the Forward Lookup of the PTR's NameHost matches the FQDN's IP address(es), then 'Not Matched'.
PtrCount => Number of PTR records for the given 'A' record.
PTRNames => NameHosts of the PTR records.
												
Author: phyoepaing3.142@gmail.com																											
Country: Myanmar(Burma)																														
Released Date: 05/04/2016
Example usage:																					  
Verify_DNS_Forward_Reverse_Record_Advanced.ps1 | Format-Table -auto
.EXAMPLE
Verify_DNS_Forward_Reverse_Record_Advanced.ps1 | Format-Table -auto
This command enumeate and verify the  'A' and 'PTR' records  on DNS server and display the results as table
.EXAMPLE
Verify_DNS_Forward_Reverse_Record_Advanced.ps1 -ExportCsv
This command enumerate and verify the  'A' and 'PTR' records  on DNS server and export the result to csv file 
with name 'Verify_DNS_Forward_Reverse_Record_Results.csv'
.EXAMPLE
Verify_DNS_Forward_Reverse_Record_Advanced.ps1 -DomainSuffix contoso.local -FilePath c:\hostnames.txt -Server 192.168.0.10
This command will verify the hostnames from 'hostnames.txt' file and query the 192.168.0.10 server with the domain name 'contoso.local'
.PARAMETER FilePath
The txt file path which contains the list of hostnames to query against the DNS server. For example, put the hostnames in txt file as belo:
host1
host2
host3
.PARAMETER DomainSuffix
Name of the domain  to append to the hostnames specifed in txt file <or> Name of the DNS zone to enumerate the 'A' records. It significantly
reduces the script run-time when the DNS server contains multiple zones.
.PARAMETER Server
The IP address of the DNS server to query the hostnames. If it is not specified and if the machine running the script is the DNS server , it uses the
'localhost' as DNS server.
.PARAMETER ExportCsv
Since the results may contain array outputs, you cannot directly save with Export-Csv cmdlet. So, use this parameter to save the result as csv file.
.LINK
You can find this script and more at: https://www.sysadminplus.blogspot.com/
#>

param([Parameter(Mandatory=$false)][string]$FilePath,[string]$DomainSuffix,[string]$Server,[switch]$ExportCsv)
### Check if the machine running the script is the DNS server, if not then prompt for hostname list and DNS server to query ####
Try {
	Get-Service -Name DNS -EA Stop	| Out-Null
	$Server = 'localhost'	
	$DefaultRecords = '_msdcs','_gc._tcp.Default-First-Site-Name._sites','_kerberos._tcp.Default-First-Site-Name._sites','_ldap._tcp.Default-First-Site-Name._sites','_gc._tcp','_kerberos._tcp','_kpasswd._tcp','_ldap._tcp','_kerberos._udp','_kpasswd._udp','_ldap._tcp.Default-First-Site-Name._sites.DomainDnsZones','_ldap._tcp.DomainDnsZones','_ldap._tcp.Default-First-Site-Name._sites.ForestDnsZones','_ldap._tcp.ForestDnsZones'
		If ($FilePath)
			{
			$HostNames = Get-Content $FilePath | sort | unique		## Select only unique hostnames, eliminating duplicate hostnames
			If (!$DomainSuffix)
				{	
				$DomainSuffix = Read-Host "Enter Domain Name [Just press 'Enter' if the FQDN is already specified in txt file]."	
				$HostNames = $HostNames | % { $_+".$DomainSuffix" }
				}
			}
		else {
				### Let the user choose one zone to enumerate records from ###
				If (!$DomainSuffix)
						{	
						$DomainSuffix = Read-Host "Enter Domain Name [Just press 'Enter' to enumerate all zones' 'A' records]."	
						$HostNames = $HostNames | % { $_+".$DomainSuffix" }
						}
				### If there is no hostnames list, then extract the 'A' records from the current DNS server. Domain Suffix will be added if specified ###
				If ($DomainSuffix)
						{
						$HostNames = Get-DnsServerZone $DomainSuffix | %{ $CurZone =$_.ZoneName;  $_ | Get-DnsServerResourceRecord | ?  { $_.HostName -ne '@' -AND $DefaultRecords -NotContains $_.HostName -AND $_.RecordType -eq 'A'}  } | % { "$($_.HostName).$DomainSuffix"  }    
						}
				else
					{
					$HostNames = Get-DnsServerZone | % { $_ | ? { $_.IsReverseLookupZone -eq $false -AND !($_.ZoneName -Match "_msdcs" -OR $_.ZoneName -Match "TrustAnchors" ) } | %{ $CurZone =$_.ZoneName;  $_ | Get-DnsServerResourceRecord | ?  { $_.HostName -ne '@' -AND $DefaultRecords -NotContains $_.HostName -AND $_.RecordType -eq 'A'}  } | % { "$($_.HostName).$CurZone"  }    }
					}
		}
	}
catch 
	{
		### Prompt for DNS server and validate with IP Address regular expression ###
		while (!$Server )
			{	
			$Server = Read-Host "Enter DNS Server IP Address"	
			while (!($Server -match "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" ))
			{ $Server = Read-Host "Enter DNS Server IP Address"	}
			}
		### Prompt for hostnames file and validate the file path ###
		while (!$FilePath -OR !(Test-Path $FilePath))
			{
			$FilePath = Read-Host "Enter the File Path"
			}
		### Check if the FilePath entered is a directory ###
		while ((Get-Item $FilePath) -is [System.IO.DirectoryInfo])
			{
			$FilePath = Read-Host "Enter the File Path"
			}
			$HostNames = Get-Content $FilePath
			### Prompt for domain suffix ###
			If (!$DomainSuffix)
				{	
				$DomainSuffix = Read-Host "Enter Domain Name.[Just press 'Enter' if the FQDN is already specified in txt file]"	
				If ($DomainSuffix)
					{	$HostNames = $HostNames | % { $_+".$DomainSuffix" }	 }
				}
			else
				{		$HostNames = $HostNames | % { $_+".$DomainSuffix" }		}
	}
### If there are duplicate hostnames then remove the duplicates ###
If (($HostNames | Group-Object | sort -Property Count -Descending | select -First 1).count -gt 1)
	{
	$HostNames = $HostNames | sort | unique
	}

### Loop and Process each FQDN record ###
$HostNames | % {
#### If 'A' Record can be resolved, then create A record object & go for PTR record, else output 'Not Found' value ####
Try { 
	$HostName = $_ 
	$AObjectIPAddress = $NULL;
	$AObjTemp = Resolve-DnsName -Name $HostName -DnsOnly -NoRecursion -Server $Server -EA Stop

	$AObject = $AObjTemp[0] | select *		## If the 'A' lookup result is an array, we'll select the first object & create custom object
	$AObject.IPaddress = $AObjTemp.IPAddress	## Inject the IP addresses from 'A' lookup result into our custom 'A' object

	$ForwardFound = "Found"
	$RevNameMatchedCount = 0;
	$RevNameUnMatchedCount = 0;

#### Loop each 'A' object, and find PTR values ####
$AObject | % { $PtrObjArray=$null;  
		$CurAObj = $_;
		Try { 
		$CurPtrNameHosts = $NULL;
		$CurPtrObj = $NULL;

		#### Loop each IP address of 'A' object and find PTR values (NameHost)	####
		$AObject.IPaddress | % {
			Try {
					$CurPtrObj	= Resolve-DnsName  -Name $_ -Type PTR -DnsOnly -NoRecursion -Server $Server -EA Stop
					[array]$CurPtrNameHosts += $CurPtrObj.NameHost
				}
			catch { $RevNameUnMatchedCount++ }
		}

		### Select the first cell from last $CurPtrObj in the previous 'Try' statement and inject 'NameHost' values from the previous 'PTR' resolution ####
		$PtrObjTemp = $CurPtrObj[0] | select *
		$PtrObjTemp.NameHost = $CurPtrNameHosts	| sort | unique		## Remove duplicate namehost and insert into PtrObjTemp
		[array]$PtrObjArray += $PtrObjTemp
		
		## Loop the PTR object array and compare each PTR's NameHosts with the hostname given in list and set $RevNameMatched value accordingly ##
		foreach ($CurPtrObj in $PtrObjArray)
			{
			$CurPtrObj.NameHost |  % {
				$CurPtrCurNameHost = $_;
				If ( $HostName -eq $CurPtrCurNameHost )
					{  $RevNameMatched = "Matched"; $RevNameMatchedCount++; }
				else {  $RevNameUnMatchedCount++;  }
				}
			}
		}
		catch {
		$RevNameMatched = ""
		}
}

If ($RevNameUnMatchedCount -ne 0 -AND $RevNameMatchedCount -eq 0 -AND $PtrObjArray.count -ne 0) { $RevNameMatched = "Not Matched" }	
If ($RevNameUnMatchedCount -ne 0 -AND $RevNameMatchedCount -ne 0 ) { $RevNameMatched = "Partially Matched" }
}
catch {
$ForwardFound = "Not Found"		## If the forward record can't be resolved, then output as 'Not Found'
$RevNameMatched	= ""
}

### Creating Object ###
$Obj = [PSCustomObject]@{
    FQDN			= 	$HostName		## FQDN of 'A' record as given in list
    IPAddress 		= 	$AObject.IPAddress		## IP addresses of the 'A' lookup
    FStatus	=	$(If ($ForwardFound -match "Not") {"Not OK"} else {"OK"} )		## If the forward record is found then OK else NOT OK.
	FFound	=	$ForwardFound		## Show if the forward record exists or does not exist.
	RFound	=	$(If ($PtrObjArray.count -eq 0) { "Not Found" } else { "Found" } )		## If the Reverse Lookup Object array is 0, then there is no PTR records for the given 'A' record.
    RStatus	=	$(If ( $PtrObjArray.count -eq 0 -OR $ForwardFound -match "Not" -OR $RevNameMatched -match "Not" -OR $RevNameMatched -match "Partially") { "Not OK" } else { "OK" } )		## If the forward record does not exist or if the PTR record namehosts does not match with the 'A' record name or if the forward name partially matches with the PTR namehosts, then "NOT OK", else OK.
	ReverseNameMatched	=	$RevNameMatched		## Status of whether PTR namehosts matches with the original hostnames given in list
	PTRNameHostResolveBack	= ""		## Set this value later after the object is created.
	PtrCount		=	$( If ($ForwardFound -match "Not") {} else { $PtrObjArray.NameHost }).Count		## Shows the number of PTR records if the Forward record is found.
	PtrNames		=	$( If ($ForwardFound -match "Not") {} else { $PtrObjArray.NameHost })		## Shows the PTR records if the Forward record is found.
}

###### Refine the Lookup of 'Partially Match' PTR Entries, looking if the Forward-Lookup of PTR's Names match any or all of the IPAddresses from forward 'A' lookup ##
$NameHostMatchA = 0;
$NameHostUnMatchA = 0;

$Obj.PtrNames | foreach { 
$CurNameHost = $_;
Try {
$ForwordLookup_PTRNameHosts_to_IP = (Resolve-DnsName -Name $CurNameHost -Server $Server -TcpOnly -NoRecursion -EA Stop).IPAddress

	#### Loop each PTR namehost and compare with the 'A' object's IP addresses	####
	$ForwordLookup_PTRNameHosts_to_IP | foreach { 
		
		$CurNameHost_IP = $_
		If ( $Obj.IPAddress -contains $CurNameHost_IP  )
			{	$NameHostMatchA++	}
		else
			{	$NameHostUnMatchA++ 	}
	}
  }
Catch 
	{$NameHostUnMatchA++	}
  }

#### If the Forward-Lookup of PTR's Names match some of the Forward-Lookup of the 'A' then set back to 'Partially Matched' and 'Not OK' ###
If ($NameHostMatchA -eq 0 -AND $NameHostUnMatchA -ne 0)
	{	$Obj.PTRNameHostResolveBack = "Not Matched"
		$Obj.RStatus = "Not OK"
	}
elseIf ($NameHostMatchA -ne 0 -AND $NameHostUnMatchA -ne 0 -AND $PtrObjArray.count -ne 0)
	{	$Obj.PTRNameHostResolveBack = "Partially Matched"
		$Obj.RStatus = "Not OK"
	}
#### If the Forward-Lookup of PTR's Names match all of the Forward-Lookup of the 'A' then set back to 'Matched' and 'OK' ###
elseIf ($NameHostUnMatchA -eq 0 -AND !($FFound -match "Not"))
	{	$Obj.PTRNameHostResolveBack = "Matched"
		$Obj.RStatus = "OK"
	}
If ($ExportCsv)
	{
	[array]$Objs += $Obj | select FQDN, @{N='IPAddress'; Exp={  $_.IPAddress -join ','  }} ,Fstatus,FFound,RStatus, ReverseNameMatched, PTRNameHostResolveBack, PtrCount, @{N='PtrNames'; Exp={  $_.PtrNames -join ','  }} 
	}
else
	{
	$Obj;
	}
}
If ($ExportCsv)
{
$Objs | export-csv -NoType  Verify_DNS_Forward_Reverse_Record_Results.csv
}