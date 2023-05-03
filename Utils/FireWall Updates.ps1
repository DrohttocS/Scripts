# Define variables for firewall rules
$ruleName = "Veeam Backup & Replication"
$description = "Allow communication between Veeam Backup & Replication components"
$protocol = "TCP"
$ports = @(2500, 2501, 9392, 6160, 6161, 3210, 4443, 3520)
$profile = "Any"

# Create a new firewall rule for each port
foreach ($port in $ports) {
    $rule = New-NetFirewallRule -DisplayName $ruleName -Description $description -Protocol $protocol -LocalPort $port -Direction Inbound -Action Allow -Profile $profile
}

# Display the new firewall rules
Get-NetFirewallRule -DisplayName $ruleName
