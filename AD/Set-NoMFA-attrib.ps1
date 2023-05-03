$AdminCred = Get-StoredCredential -Target "$env:USERNAME-Admin"
$nomfa = "no-replyd365FO","dynamicsinstaller","no-replyd365TEST","arbatch","apbatch","procbatch","HVACAutomation","envoyapp","zoom-svc","AzureDev-svc","AzureProd-svc","appstore","knowbe4-svc","d365dra-svc","applemanager","D365CEAdmin","D365CESandboxAdmin","qualyswkst-svc","O365admin","SADMIN","logicmonitor-svc","thycotic-svc","AADC_svc","azureatp","kb4admin-svc","veeam_svc"

function Update-UserMFAStatus {
    param(
        [string]$Username
    )

    # Retrieve the user object from Active Directory
    $user = Get-ADUser -Identity $Username -Properties extensionAttribute12 -ErrorAction Stop

    # Update the extensionAttribute12 property
    $user.extensionAttribute12 = "NOMFA"
Try{
    # Save the changes to Active Directory
    Set-ADUser -Instance $user -ErrorAction Stop -Credential $AdminCred 
    Write-Output "MFA status for user '$Username' has been updated to 'NO MFA'."
    }Catch{Write-Warning "Something went wrong with acct: $Username."
}
}
foreach($user in $nomfa){
Update-UserMFAStatus -Username $user
}