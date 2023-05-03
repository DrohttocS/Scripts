function  Get-DistinguishedName {
    param (
        [Parameter(Mandatory,
        ParameterSetName = 'Input')]
        [string[]]
        $CanonicalName,

        [Parameter(Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'Pipeline')]
        [string]
        $InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            $arr = $_ -split '/'
            [array]::reverse($arr)
            $output = @()
            $output += $arr[0] -replace '^.*$', 'CN=$0'
            $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
            $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
            $output -join ','
        }
        else {
            foreach ($cn in $CanonicalName) {
                $arr = $cn -split '/'
                [array]::reverse($arr)
                $output = @()
                $output += $arr[0] -replace '^.*$', 'CN=$0'
                $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
                $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
                $output -join ','
            }
        }
    }
}
$SearchName = Read-Host 'Enter name to search for'
$WC = Read-Host "Where do you want to place the Wildcard?`n 1. In the front`n 2. At the end`n 3. Both "




$SearchName = switch ( $wc )
{
    1 { "*$SearchName" }
    2 { "$SearchName*"}
    3 { "*$SearchName*" }
    default { Write-Warning 'Not a valid choice.'; break }
}
$SearchName

$SearchName = "$SearchName*"
$SearchResults = Get-ADOrganizationalUnit -Filter "name -like '$SearchName'"  -Properties * -SearchScope 2 
$ans = $null
If($SearchResults.GetType().Name -ne "Object[]"){
CLS;
$groups = Get-ADGroup -Filter * -SearchBase "$selection" | select name
$pcs = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -notlike '*Server*'}  -SearchBase $selection -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
$users = Get-ADUser -Filter * -SearchBase $selection -SearchScope Subtree
$SearchResults.DistinguishedName
Write-Host "Groups "$groups.count
Write-Host "PC's "$pcs.count
Write-Host "Users "$users.count
}else
{
$SearchResults = $SearchResults | sort CanonicalName 
$menu = @{};cls
for ($i=1;$i -le $SearchResults.count; $i++) {
    Write-Host "$i. $($SearchResults[$i-1].CanonicalName)" -ForegroundColor Green
    $menu.Add($i,($SearchResults[$i-1].DistinguishedName))
    }
[int]$ans = Read-Host 'Enter selection'
$selection = $menu.Item($ans) 



$groups = Get-ADGroup -Filter * -SearchBase "$selection" | select name
$pcs = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -notlike '*Server*'}  -SearchBase $selection -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
$users = Get-ADUser -Filter * -SearchBase $selection -SearchScope Subtree
$selection
Write-Host "Groups "$groups.count
Write-Host "PC's "$pcs.count
Write-Host "Users "$users.count
}

<#



#  Install-Module -Name CredentialManager
#  New-StoredCredential -Credentials $(Get-Credential) -Target "$env:USERNAME-Admin" -Persist Enterprise
$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"


$SB = $SearchResults.DistinguishedName
$isup=@()
$isDown=@()

#$SB = Get-DistinguishedName -CanonicalName $SB
#$SB = $SB.Replace("CN","OU")


# Get some PC's in OU
$pcs = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -notlike '*Server*'}  -SearchBase $SB -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
#See which Pcs are alive 
$pcs|Select -First 10| ForEach {
        if (test-Connection -ComputerName $_ -Count 1 -Quiet ) {  
            write-Host "$_ is alive and Pinging " -ForegroundColor Green 
            $isup += $_
                    } else 
                    { Write-Warning "$_ Not online or accessable"
             $isDown += $_
                    }     
                 } 


$ses = New-PSSession -ComputerName $isup -Credential $AdminCred

$isup = "PC218","PC218","PC218","KJH002","PC195","DS066","DS090","DS115","DS100","DS057","DS080","DS075","KDS357","DS183","PC234","DS106","DS149","PC265","PC251","PC235","PC243","DS031","ds138","PC240","DS084","DS188","DS046","DS020","DS117","DS123","DS037","DS072","DS073","DS111","DS056","DS069","DS146","DS176","DS120","PC191","DS049","DS159","PC232","DS078","DS068","PC149","PC177","DS154","PC248","PC242","PC206","DS054","PC189","PC214","PC226","DS102","DS113","DS125","DS116","DS055","DS140","DS082","DS124","DS061","DS008","DS028","DS105","DS109","DS128","DS122","PC252","DS006","DS059","DS070","PC188","DS047","PC215","KDS356","DS114","PC166","PC276","PC268","PC256","DS126","PC224","KDS358","DS139","PC223","PC271","DS184","PC207","DS187","DS179","DS133","DS103","PC194","PC209","PC222","PC-000077"

Foreach ($pc in $isup){
Get-WmiObject -Class win32_ntdomain -Filter "DomainName = 'NIDECDS'" -ComputerName $pc -Credential $AdminCred
Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $pc -Credential $AdminCred -Filter 'ipenabled = "true"'| Select-Object -Property DHCPServer
}

$isup
#>