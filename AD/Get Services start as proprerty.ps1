Enter-PSSession -ComputerName Duchess -Credential $AdminCred

Get-CimInstance -ClassName CIM_Service | Select-Object Name, StartMode, StartName