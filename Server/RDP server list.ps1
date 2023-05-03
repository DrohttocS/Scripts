$DaysInactive = 30
$time = (Get-Date).Adddays(-($DaysInactive)) 
$RDPserver = Get-ADComputer -Filter {whenChanged -ge $time -and enabled -eq $true -and OperatingSystem -Like '*Server*' } |select name | sort name
$men2= @();$menu = @{}
for ($i=1;$i -le $RDPserver.count; $i++) {
    $men2 += New-Object PSObject -Property ([ordered]@{
                TheThing          = "$i. $($RDPserver[$i-1].name )" 
        })
     $menu.Add($i,($RDPserver[$i-1].name)) 
    }


$men2 | Format-Wide -Column 4 -Force 

[int]$ans = Read-Host 'Enter selection'
$selection = $menu.Item($ans) 
mstsc /admin /v $selection 


