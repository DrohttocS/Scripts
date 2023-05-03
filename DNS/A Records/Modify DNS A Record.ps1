$dcs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }| select Name -ExpandProperty name | sort
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$session = New-PSSession -Credential $AdminCred  -ComputerName $dcs  #USLEXPINFDC01,CZOMCPINFDC01
# Update-DnsServerResourceRecordA -Name server01 -IPAddress 10.146.2.250 -ZoneName domain.com

function Update-DnsServerResourceRecordA
{
    [CmdletBinding()]
    #[OutputType([Microsoft.Management.Infrastructure.CimInstance#root/Microsoft/Windows/DNS/DnsServerResourceRecord])]
    Param
    (
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$ComputerName=$env:COMPUTERNAME,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$ZoneName=$env:USERDNSDOMAIN,
        
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]$RecordType="A",
        
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [string]$Name,
        
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [ipaddress]$IPAddress,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=5)]
        [switch]$Force=$false,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=6)]
        [int]$RRIndex=0

    )

    Begin
    {
    }
    Process
    {
        foreach ($Computer in $ComputerName) {
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                
                # Get the current resource record.
                try {
                    $OldRR = Get-DnsServerResourceRecord -ComputerName $Computer -Name $Name -RRType $RecordType -ZoneName $ZoneName -ErrorAction Stop
                    $NewRR = Get-DnsServerResourceRecord -ComputerName $Computer -Name $Name -RRType $RecordType -ZoneName $ZoneName -ErrorAction Stop
                    
                    # Ensure that the resource record exists before proceeding.
                    if ($NewRR -and $OldRR) {
                        if ($OldRR.Count) {
                            # More than one record found.
                            $NewRR[$RRIndex].RecordData.IPv4Address=[ipaddress]$IPAddress
                            $UpdatedRR = Set-DnsServerResourceRecord -NewInputObject $NewRR[$RRIndex] -OldInputObject $OldRR[$RRIndex] -ZoneName $ZoneName -ComputerName $Computer -PassThru
                            $UpdatedRR
                            }
                        else {
                            $NewRR.RecordData.IPv4Address=[ipaddress]$IPAddress
                            $UpdatedRR = Set-DnsServerResourceRecord -NewInputObject $NewRR -OldInputObject $OldRR -ZoneName $ZoneName -ComputerName $Computer -PassThru
                            $UpdatedRR
                            }
                        }
                    }
                catch {
                    # If it doesn't exist create it if the -Force parameter.
                    if ($Force) {
                        $NewRR = Add-DnsServerResourceRecordA -ComputerName $Computer -Name $Name -ZoneName $ZoneName -IPv4Address $IPAddress -PassThru -AllowUpdateAny
                        $NewRR
                        }
                    else {
                        Write-Error "Existing record $Name.$ZoneName does not exist. Use -Force to create it."
                        }
                    }
                }
            else {
                Write-Error "Unable to connect to $Computer"
                }
            }
    }
    End
    {
    }
}

$host2upd = Read-Host "Who are we updating" 
$IP   = Read-Host "IP"
$zone = "nidecds.com"

$res = Invoke-Command -Session $session ${function:Update-DnsServerResourceRecordA -Name $using:host2upd -IPAddress $using:IP -ZoneName $using:zone}
$res

Remove-PSSession $session