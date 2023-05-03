$YMD = Get-Date -UFormat "%Y%m%d"

$Import = Import-Csv -Path H:\Documents\FileSecurity\$YMD.csv


($secddl |ConvertFrom-SddlString -Type FileSystemRights |Select-Object -ExpandProperty DiscretionaryAcl) -split ‘:’


$Import| foreach {
  $output += New-Object PSObject -Property @{
                TimeCreated = $_.TimeCreated
                EventID = $_.ID
                ObjType = $_.ObjectType
                ObjName = $_.ObjectName
                User = $_.SubjectUserName
                OldSD = $_.OldSd
                NewSD = $_.NewSD
                }}
                


                $Output= @()


                $Import| foreach {
  $output = New-Object PSObject -Property @{
                TimeCreated = $_.TimeCreated
                EventID = $_.ID
                ObjType = $_.ObjectType
                ObjName = $_.ObjectName
                WhoChangedIt = $_.SubjectUserName
                OldSD = ($_.OldSd | ConvertFrom-SddlString -Type FileSystemRights |Select-Object -ExpandProperty DiscretionaryAcl) -split ‘:’
                NewSD = ($_.NewSD | ConvertFrom-SddlString -Type FileSystemRights |Select-Object -ExpandProperty DiscretionaryAcl) -split ‘:’
                Changes = Compare-Object -ReferenceObject $_.OldSd -DifferenceObject $_.NewSd
                SP2 = " "

                }}
                


                $Output

                (Compare-Object -ReferenceObject $Output.OldSd -DifferenceObject $Output.NewSd  |
                ForEach-Object {
                $_.SideIndicator = $_.SideIndicator -replace '=>','Added to group' -replace '<=','Removed from group'
                $_
                }) | sort