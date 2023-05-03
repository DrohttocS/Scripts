function Parse-WindowsEvents(){
    param(
        [Parameter(Position=1, ValueFromPipeline)]
        [object[]]$Events
    )
    process{
        $ArrayList = New-Object System.Collections.ArrayList
        $Events  | %{
            $EventObj = $_
            $EventObjFullName = $_.GetType().FullName
            $Eventmsg = ($_.message -split '\n')[0]
            if($EventObjFullName -like "System.Diagnostics.EventLogEntry"){   
                $EventObj = Get-WinEvent -LogName security -FilterXPath "*[System[EventRecordID=$($_.get_Index())]]"
            }elseif($EventObjFullName -like "System.Diagnostics.Eventing.Reader.EventLogRecord"){

            }else{
                throw "Not An Event System.Diagnostics.Eventing.Reader.EventLogRecord or System.Diagnostics.EventLogEntry"
            }
            $PsObject =  New-Object psobject
            $EventObj.psobject.properties | %{
                $PsObject | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
            }
            $XML = [xml]$EventObj.toXml()
            $PsObject2 = New-Object psobject
            $XML.Event.EventData.Data | %{
                $PsObject2 | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_."#text"
            }
            $PsObject | Add-Member -MemberType NoteProperty -Name ParsedMessage -Value $PsObject2
            $ArrayList.add($PsObject) | out-null
        }
        return $ArrayList
    }
}


Get-WinEvent -FilterHashtable $LogFilter -ComputerName twb-files  | Parse-WindowsEvents | select id -ExpandProperty parsedmessage  | Export-Csv -Path D:\UserFolders\shord2126\Documents\FileSecurity\$YMD.$YMD.csv -NoTypeInformation -Append


$Output = @()
$FilteredOutput = @()
        $LogFilter = @{
            LogName = 'Security'
            ID = 4727,4728,4729,4730,4740
            #StartTime = Get-Date -UFormat "%m/%d/%Y"
            }

        $AllEntries = Get-WinEvent -FilterHashtable $LogFilter -ComputerName twb-dc1 -ErrorAction Ignore
        $AllEntries

        



       $AllEntries | Parse-WindowsEvents | select id,Eventmsg  -ExpandProperty parsedmessage 
       
       
       | ft -AutoSize -Wrap