<#
.Synopsis
   Get a Quote for any topc
.DESCRIPTION
   Get-Quote cmdlet data harvests a/multiple quote(s) from  Web outputs into your powershell console
.EXAMPLE
   PS > Quote -Topic "success"
   For me success was always going to be a Lamborghini. But now I've got it, it just sits on my drive. 
   Curtis Jackson [50 Cent], American Rapper. From his interview with Louis Gannon for Live magazine, The Mail on Sunday (UK) newspaper, (25 October 2009). 
.EXAMPLE
   PS > "love", "genius"| Quote
   To be able to say how much you love is to love but little. 
   Petrarch, To Laura in Life (c. 1327-1350), Canzone 37 
   Doing easily what others find it difficult is talent; doing what is impossible for talent is genius. 
   Henri-Frédéric Amiel, Journal 
.EXAMPLE
   PS > Get-Quote -Topic "Genius" -Count 2
   No age is shut against great genius. 
   Seneca the Younger, Epistolæ Ad Lucilium, CII 
   
   Genius is a capacity for taking trouble. 
   Leslie Stephen, reported in Bartlett's Familiar Quotations, 10th ed. (1919) 
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   This cmdlet uses "https://en.wikiquote.org&quot; to pull the information
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-Quote {
    [CmdletBinding()]
    [Alias("Quote")]
    [OutputType([String])]
    Param(
        # Topic of the Quote
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true, 
            Position = 0)]
        [ValidateNotNullOrEmpty()][String[]]$Topic,
        [Parameter(Position = 1)][Int]$Count = 1 ,
        [Parameter(Position = 2)][Int]$Length = 150
    )

    Process {
        Foreach ($Item in $Topic) {
            $URL = "https://en.wikiquote.org/wiki/$Item"
            Try {
                $WebRequest = Invoke-WebRequest $URL
                $WebRequest.ParsedHtml.getElementsByTagName('ul')  |
                    Where-Object { $_.parentElement.classname -eq "mw-parser-output" -and $_.innertext.length -lt $Length } |
                    Get-Random -Count $Count |
                    ForEach-Object { 
                    $_.innertext
                    [Environment]::NewLine            
                }
            }
            catch {
                $_.exception
            }
        }
    }
}

$word = "Douglas Adams","Dante Alighieri","Aristotle","Emily Brontë","Buddha","Confucius","Charles Darwin","Charles Dickens","Albert Einstein","T. S. Eliot","Ralph Waldo Emerson","Richard Feynman","Mahatma Gandhi","Jesus","John Keats","Helen Keller","John F. Kennedy","Martin Luther King, Jr.","Laozi","Timothy Leary","Muhammad","Thomas Paine","Eleanor Roosevelt","Bertrand Russell","William Saroyan","William Shakespeare","George Bernard Shaw","Percy Bysshe Shelley","Starhawk","Leo Tolstoy","Virgil","Voltaire","Anonymous","American Gods","Dune","Fahrenheit 451","Leaves of Grass","The Little Prince","The Lord of the Rings","1984","Paradise Lost","Principia Discordia","The Prophet","Pride and Prejudice","A Tale of Two Cities","Casablanca","Fight Club","The Godfather","Groundhog Day","Harvey","The Hours","It's a Wonderful Life","Life of Brian","Magnolia","The Matrix","Memento","One Flew Over the Cuckoo's Nest","Schindler's List","Star Wars","Taxi Driver","Three Days of the Condor","United 93","Babylon 5","Blackadder","Breaking Bad","Buffy","The Daily Show","Game of Thrones","Gilmore Girls","Mad Men","M*A*S*H","Monty Python's Flying Circus","MST3K","Red Dwarf","Seinfeld","The Simpsons","Star Trek","The X-Files","Twin Peaks","The West Wing","Wonderfalls","Ability","Art","Beauty","Computers","Courage","Dance","Drugs","Education","Film","Flowers","Friendship","Hope","Leadership","Love","Materialism","Memory","Politics","Quotations","Religion","Science","Sexuality","Sports","Success","Television","War","Brazil","California","Canada","China","Cuba","Europe","France","Germany","India","Iran","Iraq","Ireland","Italy","Japan","London","Mexico","New York City","North Korea","Pakistan","Russia","South Korea","Spain","Sri Lanka","Turkey","United Kingdom","Vietnam","Epitaphs","Holidays","Last words","Proverbs","Slogans","Theatrical plays and musicals"

$rndword =$word | Get-Random -Count 1
cls
$q = $rndword | Get-Quote
$spillit = "From $rndword`n`n$q"
$spillit