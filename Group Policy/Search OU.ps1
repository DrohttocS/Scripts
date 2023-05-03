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

$SearchResults = Get-ADOrganizationalUnit -Filter "name -like '$SearchName'"  -Properties * -SearchScope 2 
$ans = $null
If($SearchResults.GetType().Name -ne "Object[]"){
CLS;
#$groups = Get-ADGroup -Filter * -SearchBase "$selection" | select name
#$pcs = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -notlike '*Server*'}  -SearchBase $selection -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
#$users = Get-ADUser -Filter * -SearchBase $selection -SearchScope Subtree
$SearchResults.DistinguishedName
#Write-Host "Groups "$groups.count
#Write-Host "PC's "$pcs.count
#Write-Host "Users "$users.count
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



$Results = @()


$OUList=$selection #Get-ADOrganizationalUnit -Filter * | Where-Object -FilterScript {$PSItem.distinguishedname -like $OUName}


foreach($OU in $OUList){
 $LinkedGPOs = Get-ADOrganizationalUnit -Identity $OU | select -ExpandProperty LinkedGroupPolicyObjects 
 
 foreach($LinkedGPO in $LinkedGPOs) {            
 $GPO = [adsi]"LDAP://$LinkedGPO" | select * 
 
 $properties = @{
        OUName=$OU.DistinguishedName
        GPOName=$GPO.displayName.Value
        GPOGUID=$GPO.Guid
        GPOWhenCreated=$gpo.whenChanged.Value
        GPOWhenChanged = $gpo.whenChanged.Value
 
        }
 
 $Results += New-Object psobject -Property $properties
     }
}       


<#$groups = Get-ADGroup -Filter * -SearchBase "$selection" | select name
$pcs = Get-ADComputer -Filter {Enabled -eq $true  -and OperatingSystem -notlike '*Server*'}  -SearchBase $selection -SearchScope subtree | select dnshostname -ExpandProperty dnshostname
$users = Get-ADUser -Filter * -SearchBase $selection -SearchScope Subtree
$selection
Write-Host "Groups "$groups.count
Write-Host "PC's "$pcs.count
Write-Host "Users "$users.count
#>

}
$Results | sort| ft -AutoSize -Wrap
