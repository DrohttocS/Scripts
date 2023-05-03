while($true){
    $SearchName = Read-Host "Enter name to search for`n i.e 'Hord or shord, or Sco' (or enter Q to quit)"
    if($SearchName -eq "Q"){
        break
    }
    try{
        $SearchResults = Get-Aduser -Filter "anr -like '$SearchName'" -ErrorAction Stop
        $menu = @{}
        for ($i=1;$i -le $SearchResults.count; $i++) {
            Write-Host "$i. $($SearchResults[$i-1].name)" -ForegroundColor Green
            $menu.Add($i,($SearchResults[$i-1].samaccountname))
        }
        [int]$ans = Read-Host 'Enter selection (or enter Q to quit)'
        if($ans -eq "Q"){
            break
        }
        $selection = $menu.Item($ans) 

        Get-ADUser -Identity $selection -Properties * |Select enabled,UserPrincipalName,SamAccountName,mail,DisplayName,company,telephoneNumber,NPACode,Title,Modified,whenCreated
    }
    catch{
        Write-Host "User not found." -ForegroundColor Red
    }
}
