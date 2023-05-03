$usersList = "Nagu Nambi","Paul Newman","Bingfeng Qi","Chiranjib Guha","Cole Hinton","Somnath Choudhury","Sree Kupusamy","Vamsi Vummadi","Zhu Bowei","Suhanya Kumarasamy","Sujit Mishra","John George","Dana Leva","Saravanan Palaniappan","Adi Sarivisetty","Arindam Tapaswi","Michael Gross","Amit Koul","Dipen Patel","Sandeep Komuravelli","Adam Feld","Anurag Doma","Krzysztof Kuster","Markus Kolecki","Michael Granger","Piotr Maciejewski"

$acctlist= foreach ($user in $users){
$user
$user = $user.split(" ")
$fname = $user[0]
$lName = $user[1]
get-aduser -Filter {surName -eq $lName -and GivenName -eq $fname} | select -ExpandProperty SamAccountName
 }






foreach ($user in $users){
$user = $user.split(" ")
$fname = $user[0]
$lName = $user[1]

$nsaacct = get-aduser -Filter {surName -eq $lName -and GivenName -eq $fname} | select -ExpandProperty SamAccountName
$GroupMems = Get-ADPrincipalGroupMembership $nsaacct | select -ExpandProperty name
$res= New-Object PSObject -Property ([ordered]@{

    UserAccount = $nsaacct
    GroupMembership = $GroupMems | Out-String
    })
$res | ft -AutoSize -Wrap
$acct = get-aduser -Filter {givenName -eq $fname -and surName -eq $lName -and UserPrincipalName -like "SA_*" } | select -ExpandProperty SamAccountName
$GroupMems = Get-ADPrincipalGroupMembership $acct | select -ExpandProperty name

$res= New-Object PSObject -Property ([ordered]@{

    UserAccount = $acct
    GroupMembership = $GroupMems | Out-String
    })
$res | ft -AutoSize -Wrap
}
 
#################################################################

$usersList = "Anurag Doma"
Function Get-ssGroup{
 Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $fname,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $Lname
    )

$sam = get-aduser -Filter {surName -eq $lName -and GivenName -eq $fname} | select -ExpandProperty SamAccountName
Write-host "`tChecking on $fname $lName
`nget-aduser -Filter {surName -eq $lName -and GivenName -eq $fname} | select -ExpandProperty SamAccountName`n"
$sam |  Get-ADPrincipalGroupMembership | select -ExpandProperty name |?{$_ -like "TP_*" -or $_ -like "FP_*"}

 }
 

 4 JDA Tag local owners
 update code create RDP users for local srv

 Scope complete the removal of non admin accounts / 30/60/90 or assign risk.  Scott tag push back for change to SA_ account / Issues created if not able to remidiate. / user / team / mgr // app vs user level