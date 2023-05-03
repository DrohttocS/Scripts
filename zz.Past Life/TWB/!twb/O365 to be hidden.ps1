$Groups = Get-UnifiedGroup -ResultSize Unlimited | Select DisplayName, Alias, PrimarySmtpAddress, HiddenFromExchangeClientsEnabled 
Write-Host "Processing" $Groups.Count "groups"
$Report = @()
$TeamsGroups = 0
$NoConvHistory = 0
ForEach ($G in $Groups) {
   Write-Host "Processing" $G.DisplayName 
   If ($G.HiddenFromExchangeClientsEnabled -eq $False) { # Used to be HiddenFromExchangeClients
      $ChatCheck = $Null
      $ChatCheck = (Get-MailboxFolderStatistics -Identity $G.Alias -FolderScope ConversationHistory -IncludeOldestAndNewestItems)
      If ($ChatCheck -eq $Null) { $NoConvHistory++ }
      # Check that we have a Teams compliance folder and some items are present      
      ElseIf ($ChatCheck.FolderType[1] -eq "TeamChat" -and $ChatCheck.ItemsInFolder[1] -gt 0) {
         $TeamsGroups++
         Write-Host $G.DisplayName "has" $ChatCheck.ItemsInFolder[1] "compliance records - so it's active for Teams"
         $DateLastItem = $ChatCheck.NewestItemReceivedDate[1]
         $ReportLine = [PSCustomObject][Ordered]@{
            GroupName = $G.DisplayName
            Alias     = $G.Alias
            Email     = $G.PrimarySmtpAddress
            Chats     = $ChatCheck.ItemsInFolder[1]
            LastAdded = $DateLastItem
            Hidden    = $G.HiddenFromExchangeClients }        
         $Report += $ReportLine   }
    }
}
Write-Host $TeamsGroups "groups are used by Teams and could be hidden from Exchange Clients"
$Report | Sort Chats -Descending | Select GroupName, Chats, LastAdded
$Report | Export-csv -Path c:\temp\HiddenGroups.csv -NoTypeInformation -Encoding Ascii

# $GroupList = Import-CSV "c:\temp\HiddenGroups.csv"
GroupList = $Report
ForEach ($G in $GroupList) {
     If ($G.Hidden -eq "True") {
        Write-Host "Hiding" $G.GroupName "from Exchange Clients"
        Set-UnifiedGroup -Identity $G.Alias -HiddenFromExchangeClientsEnabled:$True }
 }
