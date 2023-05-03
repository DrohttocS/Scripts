

# OneNote 2010
    $OneNotePath = "C:\Program Files (x86)\Microsoft Office\Office14\ONENOTE.EXE" 
    $arg1 = "/safeboot"

# get OneNote process and close OneNote
    $OneNote = Get-Process OneNote -ErrorAction SilentlyContinue
        if ($OneNote) {
    # try to close gracefully first
        $OneNote.CloseMainWindow()
  # kill after three seconds
  Sleep 3
        if (!$OneNote.HasExited) {
            $OneNote | Stop-Process -Force
        }
    }

# Clear OneNote Cache
    start  $OneNotePath $arg1


New-PSDrive -Name "V" -PSProvider FileSystem -Root \\twb-files\Notebooks
Set-Location V:
gci -Path $selection.FullName -Exclude "OneNote_RecycleBin" -Recurse -Directory |  Get-ChildItem -Filter *.onetoc2  | % { $_.FullName } #| Invoke-Item 