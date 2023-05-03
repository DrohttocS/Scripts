$dnshosts = "DEFRAPINFDC01","GBANDPINFDC02","EMANDSVPDC02","DESALPINFDC02","DEHENPINFDC02"

foreach ($dhost in $dnshosts){
Invoke-Command -ComputerName $dhost -ScriptBlock{
Remove-DnsServerResourceRecord -ZoneName "nidecds.com" -RRType "A" -Name GBU79PINFDC01 -ErrorAction SilentlyContinue -PassThru
} 
}

