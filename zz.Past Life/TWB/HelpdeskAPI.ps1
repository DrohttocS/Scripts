$username = "Domain+UserName:"
$password = "pwd"
$combined = $username+$password
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($combined))

$encodedCredentials = YnZiXHNob3JkMjEyNjpEcmFnMG5hc3Mh
$headers = @{ Authorization = "Basic $encodedCredentials" }

 #update a tickets comments
 $ticket = Read-Host "Ticket Number"
 $body = Read-host "What do want to add"

 $baseurl = "https://helpdesk.trailwest.bank"
 $api ="/api/comment?id=$ticket&Body=$body"
 $url = $baseurl+$api
 $result = Invoke-WebRequest -Uri $url -Method post -Headers $headers 
 $result 
