function Get-VISessionInfo{
<#
.SYNOPSIS  Retrieve vCenter session information
.DESCRIPTION The function will retrieve the open vCenter
  session, including the IP address and hostname from where
  the session was started
.NOTES  Author:  Luc Dekens
.PARAMETER AllowedDifference
  The timestamps from the Session Manager entries and the
  event objects can sometimes differ, depending on the vCenter
  activity. The default is 1 second, but this can be changed
  with this parameter. The unit for this parameter is seconds.
.EXAMPLE
  PS> Get-VISessionInfo
#>
 
  param(
  [CmdletBinding()]
  [int]$AllowedDifference = 1
  )
 
  process{
    if((Get-PowerCLIConfiguration).DefaultVIServerMode -eq "Multiple"){
      $vcenter = $defaultVIServers
    }
    else{
      $vcenter = $defaultVIServers[0]
    }
 
    foreach($vc in $vcenter){
      $sessMgr = Get-View SessionManager -Server $vc
      $oldest = ($sessMgr.SessionList | Sort-Object -Property LoginTime | Select -First 1).LoginTime
      $users = $sessMgr.SessionList | %{$_.UserName}
      $events = Get-VIEvent -MaxSamples ([int]::MaxValue) -Start $oldest.AddHours(-1) -Server $vc |
      where {$_ -is [VMware.Vim.UserLoginSessionEvent] -and $users -contains $_.UserName} |
      Sort-Object -Property CreatedTime
 
      $allowedDiffTS = New-TimeSpan -Seconds $AllowedDifference
 
      foreach($session in $sessMgr.SessionList){
        $events |
        where {[math]::Abs(($session.LoginTime.ToLocalTime() - $_.CreatedTime).Ticks) -lt $allowedDiffTS.Ticks -and
          $users -contains $_.UserName} | %{
          New-Object PSObject -Property @{
            vCenter = $vc.Name
            "Session login" = $session.LoginTime
            UserName = $_.UserName
            IPAddress = $_.IPAddress
            Hostname = [System.Net.Dns]::GetHostEntry($_.IPAddress).HostName
          }
        }
      }
    }
  }
}