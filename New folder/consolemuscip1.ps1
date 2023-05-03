function StarWars {
[console]::beep(440,500)       
[console]::beep(440,500) 
[console]::beep(440,500)       
[console]::beep(349,350)       
[console]::beep(523,150)       
[console]::beep(440,500)       
[console]::beep(349,350)       
[console]::beep(523,150)       
[console]::beep(440,1000) 
[console]::beep(659,500)       
[console]::beep(659,500)       
[console]::beep(659,500)       
[console]::beep(698,350)       
[console]::beep(523,150)       
[console]::beep(415,500)       
[console]::beep(349,350)       
[console]::beep(523,150)       
[console]::beep(440,1000)}
 StarWars

 $BeepList = @(
    @{ Pitch = 1059.274; Length = 300; };
    @{ Pitch = 1059.274; Length = 200; };
    @{ Pitch = 1188.995; Length = 500; };
    @{ Pitch = 1059.274; Length = 500; };
    @{ Pitch = 1413.961; Length = 500; };
    @{ Pitch = 1334.601; Length = 950; };

    @{ Pitch = 1059.274; Length = 300; };
    @{ Pitch = 1059.274; Length = 200; };
    @{ Pitch = 1188.995; Length = 500; };
    @{ Pitch = 1059.274; Length = 500; };
    @{ Pitch = 1587.117; Length = 500; };
    @{ Pitch = 1413.961; Length = 950; };

    @{ Pitch = 1059.274; Length = 300; };
    @{ Pitch = 1059.274; Length = 200; };
    @{ Pitch = 2118.547; Length = 500; };
    @{ Pitch = 1781.479; Length = 500; };
    @{ Pitch = 1413.961; Length = 500; };
    @{ Pitch = 1334.601; Length = 500; };
    @{ Pitch = 1188.995; Length = 500; };
    @{ Pitch = 1887.411; Length = 300; };
    @{ Pitch = 1887.411; Length = 200; };
    @{ Pitch = 1781.479; Length = 500; };
    @{ Pitch = 1413.961; Length = 500; };
    @{ Pitch = 1587.117; Length = 500; };
    @{ Pitch = 1413.961; Length = 900; };
    );

function catFact {
param(
[string]$open="It is now time for a cat fact....",
[string]$fact=(((Invoke-WebRequest -UseBasicParsing -Uri https://catfact.ninja/fact).content|ConvertFrom-Json).fact),
[int]$rate = 2
)
$speak ="$open $fact"
$v=New-Object -com SAPI.SpVoice
$voice =$v.getvoices()|where {$_.id -like "*ZIRA*"}
$v.voice= $voice
$v.rate=$rate
$v.speak($speak)
}
catfact

Function Mario{
[console]::beep(659,1000) ##E
[console]::beep(659,1000) ##E
[console]::beep(659,1000) ##E
[console]::beep(523,1000) ##C
[console]::beep(659,1000) ##E
[console]::beep(784,1000) ##G
[console]::beep(392,1000) ##g
[console]::beep(523,700) ## C
[console]::beep(392,700) ##g
[console]::beep(330,700) ##e
[console]::beep(440,1000) ##a
[console]::beep(494,1000) ##b
[console]::beep(466,700) ##a#
[console]::beep(440,700) ##a
[console]::beep(392,700) ##g
[console]::beep(659,1000) ##E
[console]::beep(784,1000) ## G
[console]::beep(880,700) ## A
[console]::beep(698,700) ## F
[console]::beep(784,650) ## G
[console]::beep(659,1000) ## E
[console]::beep(523,1000) ## C
[console]::beep(587,1000) ## D
[console]::beep(494,1000) ## B
}