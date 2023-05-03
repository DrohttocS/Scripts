Function Remove-AgedItems
{    <#
    .DESCRIPTION
        Function that can be used to remove files older than a specified age and also remove empty folders.
    .PARAMETER Path
        Specifies the target Path.
    .PARAMETER Age
     Specifies the target Age in days, e.g. Last write time of the item.
    .PARAMETER Force
     Switch parameter that allows for hidden and read-only files to also be removed.
    .PARAMETER Empty Folder
     Switch parameter to use empty folder remove function.

    .EXAMPLE
    Remove-AgedItems -Path 'C:\Users\admshord\TesfFunction' -Age 7              #Remove Files In The Target Path That Are Older Than The Specified Age (in days), Recursively.
    Remove-AgedItems -Path 'C:\Users\admshord\TesfFunction' -Age 7 -Force       #Remove Files In The Target Path That Are Older Than The Specified Age (in days), Recursively. Force will include hidden and read-only files.
    Remove-AgedItems -Path 'C:\Users\admshord\TesfFunction' -Age 0 -EmptyFolder #Remove All Empty Folders In Target Path.
    Remove-AgedItems -Path 'C:\Users\admshord\TesfFunction' -Age 7 -EmptyFolder #Remove All Empty Folders In Target Path That Are Older Than Specified Age (in days).

    .NOTES
    The -EmptyFolders switch branches the function so that it will only perform its empty folder cleanup operation, it will not affect aged files with this switch.
    It is recommended to first perform a cleanup of the aged files in the target path and them perform a cleanup of the empty folders.
    #>
    param ([String][Parameter(Mandatory = $true)]
        $Path,
        [int][Parameter(Mandatory = $true)]
        $Age,
        [switch]$Force,
        [switch]$EmptyFolder)
    
    $CurrDate = (get-date)
    if (Test-Path -Path $Path)
    {
        $Items = (Get-ChildItem -Path $Path -Recurse -Force -File)
        $AgedItems = ($Items | Where-object { $_.LastWriteTime -lt $CurrDate.AddDays(- $Age) })
        if ($EmptyFolder.IsPresent)
        {
            $Folders = @()
            ForEach ($Folder in (Get-ChildItem -Path $Path -Recurse | Where { ($_.PSisContainer) -and ($_.LastWriteTime -lt $CurrDate.AddDays(- $Age)) }))
            {
                $Folders += New-Object PSObject -Property @{
                    Object = $Folder
                    Depth = ($Folder.FullName.Split("\")).Count
                }
            }
            $Folders = $Folders | Sort Depth -Descending
            $Deleted = @()
            ForEach ($Folder in $Folders)
            {
                If ($Folder.Object.GetFileSystemInfos().Count -eq 0)
                {
                    Remove-Item -Path $Folder.Object.FullName -Force
                    Start-Sleep -Seconds 0.2
                }
            }
        }
        else
        {
            if ($Force.IsPresent)
            {
                $AgedItems | Remove-Item -Recurse -Force
            }
            
            else
            {
                $AgedItems | Remove-Item -Recurse
            }
        }
    }
    
    Else
    {
        Write-Error "Target path has not been found"
    }
}


Remove-AgedItems -Path 'C:\Users\admshord\TestFunction' -Age 7

Remove-AgedItems -Path 'C:\Users\admshord\TestFunction' -Age 0 -EmptyFolder