Function Get-MonitorInfo
{
    [CmdletBinding()]
    Param
    (
        [Parameter(
        Position=0,
        ValueFromPipeLine=$true,
        ValueFromPipeLineByPropertyName=$true)]
        [alias("CN","MachineName","Name","Computer")]
        [string[]]$ComputerName = $ENV:ComputerName
    )

    Begin {
        $pipelineInput = -not $PSBoundParameters.ContainsKey('ComputerName')
    }

    Process
    {
        Function DoWork([string]$ComputerName) {
            $ActiveMonitors = Get-WmiObject -Namespace root\wmi -Class wmiMonitorID -ComputerName $ComputerName
            $monitorInfo = @()

            foreach ($monitor in $ActiveMonitors)
            {
                $mon = $null

                $mon = New-Object PSObject -Property @{
                ManufacturerName=($monitor.ManufacturerName | % {[char]$_}) -join ''
                ProductCodeID=($monitor.ProductCodeID | % {[char]$_}) -join ''
                SerialNumberID=($monitor.SerialNumberID | % {[char]$_}) -join ''
                UserFriendlyName=($monitor.UserFriendlyName | % {[char]$_}) -join ''
                ComputerName=$ComputerName
                WeekOfManufacture=$monitor.WeekOfManufacture
                YearOfManufacture=$monitor.YearOfManufacture}

                $monitorInfo += $mon
            }
            Write-Output $monitorInfo
        }

        if ($pipelineInput) {
            DoWork($ComputerName)
        } else {
            foreach ($item in $ComputerName) {
                DoWork($item)
            }
        }
    }
}