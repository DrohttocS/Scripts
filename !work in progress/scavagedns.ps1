<#
Written by Mr. Hiraldo - Tips4teks.blogspot.com.
This script is provided AS IS and I am not responsible for any damages caused. Removing DNS records could be a problem on your network. Contact your administrator and REALLY think this through before using it.
#>
Import-Module activedirectory
#Change value DeletingEnabled to $true if you want to delete the Stale DNS Records
$DeletingEnabled = $true
Function DeleteDNSRecord($Record)
{
    $Owner = $Record.OwnerName
    $IPAddress = $Record.IPAddress

    Write-host "Deleting $Owner $IPAddress"
    Get-WmiObject -Computer $ServerName -Namespace "root\MicrosoftDNS" -Class "MicrosoftDNS_AType" -Filter "IPAddress = '$IPAddress' AND OwnerName = '$Owner'" | Remove-WmiObject
    if($?)
    {
        return "Yes"
    }
    else
    {
        return "No"
    }
}

#The variable Pathdir is used for logging later. Configure to whatever folder you'd like.
$Pathdir = "C:\Scripts\DNSScavenging"
$reportObject = @()
$NotInAD = @()
$TotalAgingInterval = 14 #It will delete records older than what specified here.
$Date = get-date -format 'yyyy.MM.dd'
$ServerName = "DC1.tips4teks.net" #Choose your DNS server here.
$ContainerName = "tips4teks.net"
$DomainZone = "DomainDNSZones." + $ContainerName

$MinTimeStamp = [Int](New-TimeSpan `
  -Start $(Get-Date("01/01/1601 00:00")) `
  -End $((Get-Date).AddDays(-$TotalAgingInterval))).TotalHours
Write-Host "Gathering DNS A Records... Please wait" -ForegroundColor Yellow
Get-WMIObject -Computer $ServerName `
  -Namespace "root\MicrosoftDNS" -Class "MicrosoftDNS_AType" `
  -Filter `
  "ContainerName='$ContainerName' AND TimeStamp<$MinTimeStamp AND TimeStamp<>0" `
 | Select-Object OwnerName, `
  @{n="TimeStamp";e={(Get-Date("01/01/1601")).AddHours($_.TimeStamp)}}, IPAddress, TTL | Export-csv -path "$Pathdir\AllStaleDNSRecords.csv"
Write-Host "Gathering DNS A Records completed!" -ForegroundColor Green
Write-Host "Searching DNS A Records in AD... Please wait" -ForegroundColor Yellow
  $DNSRecords = Import-Csv -Path "$Pathdir\AllStaleDNSRecords.csv"
  foreach ($Record in $DNSRecords)
  {
      if (($Record.OwnerName -ne $ContainerName)-and ($Record.OwnerName -ne $DomainZone))
      {
          $hostname = $Record.OwnerName
          $IPAddress = $Record.IPAddress
          $ADObject = Get-ADComputer -filter {(DNSHostName -like $hostname)} -Properties OperatingSystem, DistinguishedName
          if($ADObject -ne $null)
          {
              if(($ADObject.OperatingSystem -ne $null) -and (($ADObject.Operatingsystem -like "*Windows XP*") -or ($ADObject.OperatingSystem -like "*Windows 7*") -or ($ADObject.OperatingSystem -like "*Windows 8*") -or ($ADObject.OperatingSystem -like "Mac OS X")))
              {
                  $output = "" | Select DNSOwnerName, ADName,OperatingSystem, IPAddress, TTL, TimeStamp, Deleted, DistinguishedName
                  $output.DNSOwnerName = $hostname
                  $output.ADName = $ADObject.Name
                  $output.OperatingSystem = $ADObject.OperatingSystem
                  $output.IPAddress = $IPAddress
                  $output.TTL = $Record.TTL
                  $output.TimeStamp = $Record.TimeStamp
                  $output.DistinguishedName = $ADObject.DistinguishedName              
                  if ($DeletingEnabled -eq $true)
                  {
                    $output.Deleted = DeleteDNSRecord($Record)
                  }
                  else
                  {
                    $output.Deleted = "Deleting Not Enabled"
                  }
               
                  $reportObject += $output

              }
           

          }
          else
              {
                Write-Host "Record doesn't exist in AD and will be deleted." $hostname
                $Erroutput = "" | Select DNSOwnerName, IPAddress, TTL, TimeStamp, Deleted
                $Erroutput.DNSOwnerName = $Record.OwnerName
                $Erroutput.IPAddress = $Record.IPAddress
                $Erroutput.TTL = $Record.TTL
                $Erroutput.TimeStamp = $Record.TimeStamp
                if ($DeletingEnabled -eq $true)
                {
                    $Erroutput.Deleted = DeleteDNSRecord($Record)
                }
                else
                {
                    $Erroutput.Deleted = "Deleting Not Enabled"
                }
   
                $NotInAD += $Erroutput
              }

      }

  }
  Write-Host "Scavenging Maintenance Complete! Exporting to CSV.." -ForegroundColor Green
  $reportObject | Export-csv -path "$Pathdir\DNSRecords-to-delete-with-ADinfo-$Date.csv"
  $NotInAD | Export-csv -path "$Pathdir\DNSRecords-NotInAD-Deleted-$Date.csv"

$to = "MrHiraldo@tips4teks.net"
$Subject = "DNS Scavenging Report for $Date"
$Body = "Hello Team,`nThe following reports attached show the DNS records scanvenged from zone $ContainerName"
$Relay = "relay.tips4teks.net"
$From = "DNSScavenging@tips4teks.net"
$Attach = "$Pathdir\DNSRecords-to-delete-with-ADinfo-$Date.csv", "$Pathdir\DNSRecords-NotInAD-Deleted-$Date.csv"
#Send the Email and attachment
Send-MailMessage -to $to -Subject $Subject -Body $Body -SmtpServer $Relay -Attachments $Attach -From $From