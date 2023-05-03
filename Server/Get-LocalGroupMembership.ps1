Function Get-LocalGroupMembership {
<#
    .SYNOPSIS
        Recursively list all members of a specified Local group.

    .DESCRIPTION
        Recursively list all members of a specified Local group. This can be run against a local or
        remote system or systems. Recursion is unlimited unless specified by the -Depth parameter.

        Alias: glgm

    .PARAMETER Computername
        Local or remote computer/s to perform the query against.

        Default value is the local system.

    .PARAMETER Group
        Name of the group to query on a system for all members.

        Default value is 'Administrators'

    .PARAMETER Depth
        Limit the recursive depth of a query. 

        Default value is 2147483647.

    .PARAMETER Throttle
        Number of concurrently running jobs to run at a time

        Default value is 10

    .NOTES
        Author: Boe Prox
        Created: 8 AUG 2013
        Version 1.0 (8 AUG 2013):
            -Initial creation

    .EXAMPLE
        Get-LocalGroupMembership

        Name              ParentGroup       isGroup Type   Computername Depth
        ----              -----------       ------- ----   ------------ -----
        Administrator     Administrators      False Domain DC1              1
        boe               Administrators      False Domain DC1              1
        testuser          Administrators      False Domain DC1              1
        bob               Administrators      False Domain DC1              1
        proxb             Administrators      False Domain DC1              1
        Enterprise Admins Administrators       True Domain DC1              1
        Sysops Admins     Enterprise Admins    True Domain DC1              2
        Domain Admins     Enterprise Admins    True Domain DC1              2
        Administrator     Enterprise Admins   False Domain DC1              2
        Domain Admins     Administrators       True Domain DC1              1
        proxb             Domain Admins       False Domain DC1              2
        Administrator     Domain Admins       False Domain DC1              2
        Sysops Admins     Administrators       True Domain DC1              1
        Org Admins        Sysops Admins        True Domain DC1              2
        Enterprise Admins Sysops Admins        True Domain DC1              2       

        Description
        -----------
        Gets all of the members of the 'Administrators' group on the local system.        

    .EXAMPLE
        Get-LocalGroupMembership -Group 'Administrators' -Depth 1

        Name              ParentGroup    isGroup Type   Computername Depth
        ----              -----------    ------- ----   ------------ -----
        Administrator     Administrators   False Domain DC1              1
        boe               Administrators   False Domain DC1              1
        testuser          Administrators   False Domain DC1              1
        bob               Administrators   False Domain DC1              1
        proxb             Administrators   False Domain DC1              1
        Enterprise Admins Administrators    True Domain DC1              1
        Domain Admins     Administrators    True Domain DC1              1
        Sysops Admins     Administrators    True Domain DC1              1   

        Description
        -----------
        Gets the members of 'Administrators' with only 1 level of recursion.         

#>
[cmdletbinding()]
Param (
    [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [Alias('CN','__Server','Computer','IPAddress')]
    [string[]]$Computername = $env:COMPUTERNAME,
    [parameter()]
    [string]$Group = "Administrators",
    [parameter()]
    [int]$Depth = ([int]::MaxValue),
    [parameter()]
    [Alias("MaxJobs")]
    [int]$Throttle = 10
)
Begin {
    $PSBoundParameters.GetEnumerator() | ForEach {
        Write-Verbose $_
    }
    #region Extra Configurations
    Write-Verbose ("Depth: {0}" -f $Depth)
    #endregion Extra Configurations
    #Define hash table for Get-RunspaceData function
    $runspacehash = @{}
    #Function to perform runspace job cleanup
    Function Get-RunspaceData {
        [cmdletbinding()]
        param(
            [switch]$Wait
        )
        Do {
            $more = $false         
            Foreach($runspace in $runspaces) {
                If ($runspace.Runspace.isCompleted) {
                    $runspace.powershell.EndInvoke($runspace.Runspace)
                    $runspace.powershell.dispose()
                    $runspace.Runspace = $null
                    $runspace.powershell = $null                 
                } ElseIf ($runspace.Runspace -ne $null) {
                    $more = $true
                }
            }
            If ($more -AND $PSBoundParameters['Wait']) {
                Start-Sleep -Milliseconds 100
            }   
            #Clean out unused runspace jobs
            $temphash = $runspaces.clone()
            $temphash | Where {
                $_.runspace -eq $Null
            } | ForEach {
                Write-Verbose ("Removing {0}" -f $_.computer)
                $Runspaces.remove($_)
            }             
        } while ($more -AND $PSBoundParameters['Wait'])
    }

    #region ScriptBlock
        $scriptBlock = {
        Param ($Computer,$Group,$Depth,$NetBIOSDomain,$ObjNT,$Translate)            
        $Script:Depth = $Depth
        $Script:ObjNT = $ObjNT
        $Script:Translate = $Translate
        $Script:NetBIOSDomain = $NetBIOSDomain
        Function Get-LocalGroupMember {
            [cmdletbinding()]
            Param (
                [parameter()]
                [System.DirectoryServices.DirectoryEntry]$LocalGroup
            )
            # Invoke the Members method and convert to an array of member objects.
            $Members= @($LocalGroup.psbase.Invoke("Members"))
            $Counter++
            ForEach ($Member In $Members) {                
                Try {
                    $Name = $Member.GetType().InvokeMember("Name", 'GetProperty', $Null, $Member, $Null)
                    $Path = $Member.GetType().InvokeMember("ADsPath", 'GetProperty', $Null, $Member, $Null)
                    # Check if this member is a group.
                    $isGroup = ($Member.GetType().InvokeMember("Class", 'GetProperty', $Null, $Member, $Null) -eq "group")
                    If (($Path -like "*/$Computer/*")) {
                        $Type = 'Local'
                    } Else {$Type = 'Domain'}
                    New-Object PSObject -Property @{
                        Computername = $Computer
                        Name = $Name
                        Type = $Type
                        ParentGroup = $LocalGroup.Name[0]
                        isGroup = $isGroup
                        Depth = $Counter
                    }
                    If ($isGroup) {
                        # Check if this group is local or domain.
                        #$host.ui.WriteVerboseLine("(RS)Checking if Counter: {0} is less than Depth: {1}" -f $Counter, $Depth)
                        If ($Counter -lt $Depth) {
                            If ($Type -eq 'Local') {
                                If ($Groups[$Name] -notcontains 'Local') {
                                    $host.ui.WriteVerboseLine(("{0}: Getting local group members" -f $Name))
                                    $Groups[$Name] += ,'Local'
                                    # Enumerate members of local group.
                                    Get-LocalGroupMember $Member
                                }
                            } Else {
                                If ($Groups[$Name] -notcontains 'Domain') {
                                    $host.ui.WriteVerboseLine(("{0}: Getting domain group members" -f $Name))
                                    $Groups[$Name] += ,'Domain'
                                    # Enumerate members of domain group.
                                    Get-DomainGroupMember $Member $Name $True
                                }
                            }
                        }
                    }
                } Catch {
                    $host.ui.WriteWarningLine(("GLGM{0}" -f $_.Exception.Message))
                }
            }
        }

        Function Get-DomainGroupMember {
            [cmdletbinding()]
            Param (
                [parameter()]
                $DomainGroup, 
                [parameter()]
                [string]$NTName, 
                [parameter()]
                [string]$blnNT
            )
            Try {
                If ($blnNT -eq $True) {
                    # Convert NetBIOS domain name of group to Distinguished Name.
                    $objNT.InvokeMember("Set", "InvokeMethod", $Null, $Translate, (3, ("{0}{1}" -f $NetBIOSDomain.Trim(),$NTName)))
                    $DN = $objNT.InvokeMember("Get", "InvokeMethod", $Null, $Translate, 1)
                    $ADGroup = [ADSI]"LDAP://$DN"
                } Else {
                    $DN = $DomainGroup.distinguishedName
                    $ADGroup = $DomainGroup
                }         
                $Counter++   
                ForEach ($MemberDN In $ADGroup.Member) {
                    $MemberGroup = [ADSI]("LDAP://{0}" -f ($MemberDN -replace '/','\/'))
                    New-Object PSObject -Property @{
                        Computername = $Computer
                        Name = $MemberGroup.name[0]
                        Type = 'Domain'
                        ParentGroup = $NTName
                        isGroup = ($MemberGroup.Class -eq "group")
                        Depth = $Counter
                    }
                    # Check if this member is a group.
                    If ($MemberGroup.Class -eq "group") {              
                        If ($Counter -lt $Depth) {
                            If ($Groups[$MemberGroup.name[0]] -notcontains 'Domain') {
                                Write-Verbose ("{0}: Getting domain group members" -f $MemberGroup.name[0])
                                $Groups[$MemberGroup.name[0]] += ,'Domain'
                                # Enumerate members of domain group.
                                Get-DomainGroupMember $MemberGroup $MemberGroup.Name[0] $False
                            }                                                
                        }
                    }
                }
            } Catch {
                $host.ui.WriteWarningLine(("GDGM{0}" -f $_.Exception.Message))
            }
        }
        #region Get Local Group Members
        $Script:Groups = @{}
        $Script:Counter=0
        # Bind to the group object with the WinNT provider.
        $ADSIGroup = [ADSI]"WinNT://$Computer/$Group,group"
        Write-Verbose ("Checking {0} membership for {1}" -f $Group,$Computer)
        $Groups[$Group] += ,'Local'
        Get-LocalGroupMember -LocalGroup $ADSIGroup
        #endregion Get Local Group Members
    }
    #endregion ScriptBlock
    Write-Verbose ("Checking to see if connected to a domain")
    Try {
        $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $Root = $Domain.GetDirectoryEntry()
        $Base = ($Root.distinguishedName)

        # Use the NameTranslate object.
        $Script:Translate = New-Object -comObject "NameTranslate"
        $Script:objNT = $Translate.GetType()

        # Initialize NameTranslate by locating the Global Catalog.
        $objNT.InvokeMember("Init", "InvokeMethod", $Null, $Translate, (3, $Null))

        # Retrieve NetBIOS name of the current domain.
        $objNT.InvokeMember("Set", "InvokeMethod", $Null, $Translate, (1, "$Base"))
        [string]$Script:NetBIOSDomain =$objNT.InvokeMember("Get", "InvokeMethod", $Null, $Translate, 3)  
    } Catch {Write-Warning ("{0}" -f $_.Exception.Message)}         

    #region Runspace Creation
    Write-Verbose ("Creating runspace pool and session states")
    $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
    $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
    $runspacepool.Open()  

    Write-Verbose ("Creating empty collection to hold runspace jobs")
    $Script:runspaces = New-Object System.Collections.ArrayList        
    #endregion Runspace Creation
}

Process {
    ForEach ($Computer in $Computername) {
        #Create the powershell instance and supply the scriptblock with the other parameters 
        $powershell = [powershell]::Create().AddScript($scriptBlock).AddArgument($computer).AddArgument($Group).AddArgument($Depth).AddArgument($NetBIOSDomain).AddArgument($ObjNT).AddArgument($Translate)

        #Add the runspace into the powershell instance
        $powershell.RunspacePool = $runspacepool

        #Create a temporary collection for each runspace
        $temp = "" | Select-Object PowerShell,Runspace,Computer
        $Temp.Computer = $Computer
        $temp.PowerShell = $powershell

        #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
        $temp.Runspace = $powershell.BeginInvoke()
        Write-Verbose ("Adding {0} collection" -f $temp.Computer)
        $runspaces.Add($temp) | Out-Null

        Write-Verbose ("Checking status of runspace jobs")
        Get-RunspaceData @runspacehash   
    }
}
End {
    Write-Verbose ("Finish processing the remaining runspace jobs: {0}" -f (@(($runspaces | Where {$_.Runspace -ne $Null}).Count)))
    $runspacehash.Wait = $true
    Get-RunspaceData @runspacehash

    #region Cleanup Runspace
    Write-Verbose ("Closing the runspace pool")
    $runspacepool.close()  
    $runspacepool.Dispose() 
    #endregion Cleanup Runspace    
}
}



# $servers = "dc3.RWC.com","dc1.RWC.com","dc2.RWC.com","WA9502WDC2.RWC.com","RWCCERT.RWC.com","RDS-TS-License.RWC.com","RWCAUTH.RWC.com","VDICS01.RWC.com","NETENGSVR2.RWC.com","RWCVCS.RWC.com","RWCCAS.RWC.com","RWCHTS.RWC.com","RWCMAILDB.RWC.com","RWCSPFE.RWC.com","RWCCARDIODB.RWC.com","VDIVCS.RWC.com","VDICONNECT.RWC.com","DEMETER.RWC.com","DMCPRINT.RWC.com","VIEWVCS.RWC.com","VCENTER01.RWC.com","VIEWVC.RWC.com","XENAPP1.RWC.com","RWCSCDWDB.RWC.com","vdi-vc.RWC.com","DEACWDS.RWC.com","RWCBOSTWICK.RWC.com","ABRA2.RWC.com","PRIVCS.RWC.com","rwcprint.RWC.com","WA9502VMWAPP01.RWC.com","XEN23.RWC.com","XEN24.RWC.com","XEN20.RWC.com","XEN25.RWC.com","WA9502VMWJBOSSP.RWC.com","MATRIXDB2.RWC.com","XEN30.RWC.com","XEN27.RWC.com","XEN26.RWC.com","XEN29.RWC.com","XEN12.RWC.com","XEN18.RWC.com","XEN19.RWC.com","XEN22.RWC.com","XEN21.RWC.com","RWCLABELPR.RWC.com","NETENGSVR1.RWC.com","VDICS2.RWC.com","VDICS1.RWC.com","NETENGDB.RWC.com","WA9502NUANCESN.RWC.com","WA9502VMWSQL01.RWC.com","RWC2.RWC.com","DTSP5.RWC.com","XEN28.RWC.com","rwcariadb.RWC.com","XENAPPDB.RWC.com","COPIA-WEB.RWC.com","kript02.RWC.com","research.RWC.com","WA9502MAN02.RWC.com","WA9502VMWDTS1.RWC.com","RWCBREEZE.RWC.com","XEN43.RWC.com","KRIPT03.RWC.com","omnicaresvr01.RWC.com","FAXCOM.RWC.com","SILO.RWC.com","rwcgdi1.RWC.com","RWCSECURITY.RWC.com","kript01.RWC.com","CENTRICITYPROD.RWC.com","RWCSQLAUDIT.RWC.com","WA9502FS1.RWC.com","ge-mars.RWC.com","RWCADW.RWC.com","EMRWEBREPORT.RWC.com","RWCDATACON.RWC.com","EMRWEBUPGRADE.RWC.com","XENAPPWI.RWC.com","RWCINDXLOGICDB.RWC.com","RWCSPDB.RWC.com","JBOSS.RWC.com","MATRIXFE.RWC.com","WA9502PORTAL1.RWC.com","emrwebtest.RWC.com","XEN31.RWC.com","rwcprint-MFP.RWC.com","rwcsql01.RWC.com","NETENGSVR5.RWC.com","XEN15.RWC.com","ctx15.RWC.com","rwcariafs.RWC.com","RWCAIRIAHL7.RWC.com","WA9502MAN01.RWC.com","XEN16.RWC.com","KRIPT03DB.RWC.com","RWCWSUS1.RWC.com","XEN67.RWC.com","XEN68.RWC.com","XEN07.RWC.com","XEN69.RWC.com","RWCPROREV.RWC.com","MICROCALL.RWC.com","dtsp4.RWC.com","XEN46.RWC.com","RWCSPINDX.RWC.com","casbar.RWC.com","RWCSCAN.RWC.com","IRONVIEW.RWC.com","SASTEST.RWC.com","XEN-TRAINER.RWC.com","XEN70.RWC.com","provat02.RWC.com","ctx00.RWC.com","XEN36.RWC.com","emrweb01.RWC.com","XEN32.RWC.com","WA9502SP1APP1.RWC.com","XEN35.RWC.com","XEN39.RWC.com","XEN34.RWC.com","XEN41.RWC.com","XEN05.RWC.com","XEN33.RWC.com","XEN37.RWC.com","XEN42.RWC.com","XEN57.RWC.com","XEN47.RWC.com","WA9502EMCMAN01.RWC.com","XEN52.RWC.com","KRIPT04.RWC.com","XEN45.RWC.com","XEN51.RWC.com","XEN04.RWC.com","XEN55.RWC.com","PRIVCSDB.RWC.com","XEN49.RWC.com","WA9502VMPROT01.RWC.com","XEN38.RWC.com","WA9502PROFILES.RWC.com","XEN40.RWC.com","ORCHARD2.RWC.com","XEN06.RWC.com","XEN65.RWC.com","XEN01.RWC.com","XEN50.RWC.com","orchard1.RWC.com","XEN14.RWC.com","XEN63.RWC.com","XEN54.RWC.com","XEN56.RWC.com","XEN64.RWC.com","XEN53.RWC.com","Footprints.RWC.com","RWCEFOLDERS.RWC.com","SMTPRELAY.RWC.com","rwcariaharp.RWC.com","XEN00.RWC.com","VIEWVCDB.RWC.com","XEN59.RWC.com","XEN58.RWC.com","WA9502NUANCE.RWC.com","XEN60.RWC.com","DTSP6.RWC.com","RWC2JOBS.RWC.com","MATRIXDB1.RWC.com","XEN61.RWC.com","RWC4FRONT.RWC.com","XEN48.RWC.com","RWCPAGER.RWC.com","ABRA.RWC.com","RWCFTP.RWC.com","XEN62.RWC.com","WA9502MAN03.RWC.com","ORCHARDHL7.RWC.com","CLOVERLEAF.RWC.com","COPIA-DB.RWC.com","WA9502SP1FE2.RWC.com","dtsp3.RWC.com","RWCDATACON-test.RWC.com","RWCRLWEB.RWC.com","XEN03.RWC.com","TESTORCHARD1.RWC.com","XENDEV.RWC.com","RWCINFO.RWC.com","DTSP1.RWC.com","WA9502SP1FE1.RWC.com","KMS-MANAGE.RWC.com","ROCK0.RWC.com","provat01.RWC.com","dtsp2.RWC.com","hera.RWC.com","RWCHRWEB.RWC.com","RWCRA.RWC.com","XENZDC1.RWC.com","XEN72.RWC.com","XEN73.RWC.com","XEN66.RWC.com","XEN74.RWC.com","XEN75.RWC.com","XEN76.RWC.com","WA9502PRTICA.RWC.com","WA9502VMCTX0001.RWC.com","WA9502VMCTX0002.RWC.com","RWCINDXLOGIC.RWC.com","WA9502VERA.RWC.com","WA9502WUSR001.RWC.com","WA9502DEVTST1.RWC.com","XENICA01.RWC.com","XEN101.RWC.com","WA9502SOLAPP.RWC.com","WA9502SOLDB.RWC.com","emrupgrade.RWC.com","CENTRICITYDEV.RWC.com","CENTRICITYRPT.RWC.com","WA9502WPACS2HL7.RWC.com","WA9502WIDM001.RWC.com","WA9502EDGESTWEB.RWC.com","WA9502EDGESTDB.RWC.com","XEN71.RWC.com","WA9502DEVTST2.RWC.com","WA9502MIG01.RWC.com","XENICA02.RWC.com","WA9502SWDB.RWC.com","WA9502FMAPP1.RWC.com","WA9502WSPDB.RWC.com","WA9502WSPAPP.RWC.com","WA9502BHDB1.RWC.com","XEN17.RWC.com","WA9502WIMCT001.RWC.com","WA9502WIMCAP001.RWC.com","WA9502WIMCDB001.RWC.com","WA9502WCPAP01.RWC.com","WA9502WCPDB01.RWC.com","XEN11.RWC.com","WA9502WAIK.RWC.com","WA9502RAPID1.RWC.com","WA9502SOLDB01.RWC.com","WA9502WPW01.RWC.com","WA9502WONEX02.RWC.com","WA9502SQLMGMT01.RWC.com","ABRALAB.RWC.com","MATRIXWRK1.RWC.com","MATRIXWRK2.RWC.com","MATRIXWRK3.RWC.com","WA9502WITD001.RWC.com","WA9502WSMPP01.RWC.com","WA9502WSMPP02.RWC.com","WA9502SRM01.RWC.com","XEN13.RWC.com","XEN44.RWC.com","WA9502WPHCFG1.RWC.com","WA9502WBACKUP1.RWC.com","WA9502WBACKUP01.RWC.com","WA9502WSMPP01-P.RWC.com","WA9502WSMPP04.RWC.com","WA9502VPRINT1.RWC.com","XEN90.RWC.com","WA9502WTMSXE001.RWC.com","WA9502WVATBOX.RWC.com","WA9502ARIADB001.RWC.com","WA9502ARIADB002.RWC.com","WA9502SP1DB1.RWC.com","WA9502ARIAIEM01.RWC.com","WA9502WPIPS01.RWC.com","WA9502WONEX01.RWC.com","XEN77.RWC.com","WA9502SWAPP.RWC.com","WA9502WVCENTER001.RWC.com","WA9502WEMR01T.RWC.com","WA9502WDOCMAN1.RWC.com","WA9502WEPRE1.RWC.com","WA9502WEPREDB.RWC.com","WA9502WJBOSS1.RWC.com","WA9502WXENWI.RWC.com","WA9502WXENDB.RWC.com","WA9502WXENZDC.RWC.com","WA9502WXENLIC.RWC.com","WA9502WXENEDGE.RWC.com","WA9502WXEN1.RWC.com","WA9502WCENT1.RWC.com","WA9502WQIE1.RWC.com","WA9502WCOPIA1.RWC.com","WA9502WVMCOLL1.RWC.com","WA9502WHARVEST1.RWC.com","WA9502WCOPIADB.RWC.com","WA9502WNETINV1.RWC.com","WA9502WSCCM12.RWC.com","WA9502ORCHHL7T001.RWC.com","TEST-P2V-SERVER.RWC.com","WA9502WIPMON001.RWC.com","WA9502WLYNC01.RWC.com","WA9502WRWCSSRS1.RWC.com","WA9502WLEDGE01.RWC.com","XEN78.RWC.com","XEN79.RWC.com","XEN80.RWC.com","XEN82.RWC.com","XEN83.RWC.com","XEN81.RWC.com","WA9502WMEAD01.RWC.com","WA9502WDB01.RWC.com","WA9502WSCDB01.RWC.com","WA9502WPRINT001.RWC.com","XEN6510.RWC.com","WA9502TSPROFILES001.RWC.com","WA9502CXR01.RWC.com","WA1501WCXA01.RWC.com","WA1501WCLIC01.RWC.com","WA1501WCXA02.RWC.com","WA1501WTMSCH01.RWC.com"
# $servers | Get-LocalGroupMembership | where name | Export-Csv C:\admin\localadmin_rwc.txt
# $servers = "chsdc01.chsspokane.local","wa1501wdc005.chsspokane.local","CHSDC03.chsspokane.local","CHSDC02.chsspokane.local","CHSRDSLIC01.chsspokane.local","ehstms01.chsspokane.local","CHSCLICKON01.chsspokane.local","chsrapidcomm01.chsspokane.local","S023398.chsspokane.local","EHSPRINT01.chsspokane.local","DMCDMSINT83.chsspokane.local","DMCDMS80.chsspokane.local","DMCRNet.chsspokane.local","CHSVMWAREVC01.chsspokane.local","ehscbord01.chsspokane.local","WA1501WGHX001.chsspokane.local","WA1501DRVC01.chsspokane.local","IBM-x3550-M3.chsspokane.local","WA1501CT.chsspokane.local","WA1501CA.chsspokane.local","WA1501C9.chsspokane.local","WA1501C8.chsspokane.local","WA1501C7.chsspokane.local","WA1501C6.chsspokane.local","WA1501CB.chsspokane.local","WA1501WVNAVS001.chsspokane.local","WA9502TS03.chsspokane.local","CHSMTDATAREP01.chsspokane.local","WA1911WCENT6.chsspokane.local","CHSNICVUEREV.chsspokane.local","EHSHL7.chsspokane.local","CHSMTARCH01.chsspokane.local","CHSWDS01.chsspokane.local","CHSDOCUWAREDB01.chsspokane.local","VHMCINW01.chsspokane.local","wa1501wdfapp002.chsspokane.local","CHSEXVOICE01.chsspokane.local","WA1501METER01.chsspokane.local","ICMEDWEB.chsspokane.local","CHSDSACCUNET01.chsspokane.local","chsepiphany01.chsspokane.local","WA1911WCENT9.chsspokane.local","CHSEDGESTWEB.chsspokane.local","WA1501WDFAPP003.chsspokane.local","CHSNS01.chsspokane.local","chscitrixps04.chsspokane.local","ehssandman01.chsspokane.local","chscitrixps05.chsspokane.local","CHSSEP01.chsspokane.local","CHSEMPIBET.chsspokane.local","CHSCLVRLFT01.chsspokane.local","chsekm01.chsspokane.local","WA1911WCPN002.chsspokane.local","CHSDSACCUNET01T.chsspokane.local","respondernet.chsspokane.local","WA1501ACUODB1.chsspokane.local","DYH-PDI01.chsspokane.local","WA1911WASOBWEB.chsspokane.local","CHSEMPIFET.chsspokane.local","CHSMTDATAREP02.chsspokane.local","WA1501ACUOAPP5.chsspokane.local","CHSSAM01.chsspokane.local","WA1501WASAPP001.chsspokane.local","CHSDOCUWARE01W.chsspokane.local","CHSDEV01.chsspokane.local","ehsgoodroe01.chsspokane.local","ehsapps01.chsspokane.local","CHSEMPIBE.chsspokane.local","WA1501WASWEB001.chsspokane.local","EHSRals01.chsspokane.local","CHSEMPIFE.chsspokane.local","EHSINW01.chsspokane.local","WA1501CFSEC01.chsspokane.local","ehssql03.chsspokane.local","CHSMEDIA01.chsspokane.local","CHSFTP01.chsspokane.local","DYH-LIB01.chsspokane.local","USWA0085961W01.chsspokane.local","WA1911WCPN001.chsspokane.local","ehscbord01t.chsspokane.local","CHSMGMT01.chsspokane.local","chswebsvr01.chsspokane.local","ehsdepts01.chsspokane.local","chsmmdapp01.chsspokane.local","CHSSQLAUDIT.chsspokane.local","WA1911WCENT8.chsspokane.local","CHSTSMRPT01.chsspokane.local","CHSCITRIXGW01.chsspokane.local","chsact01.chsspokane.local","CHSDOCUWARE01.chsspokane.local","CHSEMPIDBT.chsspokane.local","CHSIPATTCON1.chsspokane.local","EHSHOME01.chsspokane.local","vhmdosetrack01.chsspokane.local","PSCRIBE2B593.chsspokane.local","ehskronos01t.chsspokane.local","PSCRIBE2D033.chsspokane.local","chswcs01.chsspokane.local","CHSEMPIDB.chsspokane.local","DMC-NWC-PROD.chsspokane.local","CHSVADP01.chsspokane.local","chsmmd01w.chsspokane.local","CHSTSM01.chsspokane.local","CHSMTPIC01.chsspokane.local","WA1501ACUOCACHE.chsspokane.local","CHSCLVRLF01.chsspokane.local","WA1501WDFAPP001.chsspokane.local","pspt1pm01.chsspokane.local","CHSCISCOWCS01.chsspokane.local","chsmmd01t.chsspokane.local","CHSMTBACKUP02.chsspokane.local","WA1501WDFAPP004.chsspokane.local","WA1911WCPN003.chsspokane.local","ehssql02.chsspokane.local","CHSSCCM01.chsspokane.local","WA1501WSCOPIA01.chsspokane.local","CHSCITRIXPS02.chsspokane.local","CHSDOCUWARET01.chsspokane.local","CHSPICISSECLINK.chsspokane.local","ICMEDAPP.chsspokane.local","vhmccadwell01.chsspokane.local","WA1501ACUOAPP1.chsspokane.local","CHSFAX01.chsspokane.local","CHSNICVUEDATA.chsspokane.local","CHSMMDDB01.chsspokane.local","CHSINTERBIT01.chsspokane.local","CHSIPORTAL01.chsspokane.local","chsdocuscript01.chsspokane.local","WA1501ACUOASX1.chsspokane.local","WA1911WCPN004.chsspokane.local","WA1911WCPN006.chsspokane.local","WA1501SRM01.chsspokane.local","DMC-NWC-T01.chsspokane.local","wa1501vsa001.chsspokane.local","CHSCITRIXPS03.chsspokane.local","ehssql01.chsspokane.local","EHSOBSVR01.chsspokane.local","EHSMEDQDOCQ01.chsspokane.local","EHSKRONOSDB01.chsspokane.local","pscriberec01.chsspokane.local","WA1501ACUOAPP2.chsspokane.local","WA1501ACUOAPP3.chsspokane.local","chsnicvueapp.chsspokane.local","CHSMTBACKUP01.chsspokane.local","CHSDOCUWAREWF01.chsspokane.local","EHSGROUPS01.chsspokane.local","WA1501ACUOTEST1.chsspokane.local","CHSOPS01.chsspokane.local","WA1501WTMS01.chsspokane.local","CHSTSM02.chsspokane.local","ICMEDDB.chsspokane.local","CHSSCRIPT01.chsspokane.local","WA1501CU.chsspokane.local","CHSCITRIXPS01.chsspokane.local","CHSDHCP01.chsspokane.local","WA1501SNXT001.chsspokane.local","dmcdosetrack01.chsspokane.local","WA1501SNXT002.chsspokane.local","CHSCCURE01.chsspokane.local","CHSNICVUEDB.chsspokane.local","ADX10M-001.chsspokane.local","chswebsvr02.chsspokane.local","chsmmd01ew.chsspokane.local","CHSEDGESTDB.chsspokane.local","WA1501DRSRM1.chsspokane.local","ehsapps02.chsspokane.local","WA1501ACUOAPP4.chsspokane.local","CHSEFORMS01.chsspokane.local","ehscadwell01.chsspokane.local","WA1501DRSRM2.chsspokane.local","EHSKRONOSAPPS01.chsspokane.local","WA1501WVHA1.chsspokane.local","WA1501WVHA2.chsspokane.local","WA1501WPWEBAPP1.chsspokane.local","WA1501WPWEBDB1.chsspokane.local","WA1501WPWEBWRX1.chsspokane.local","CHSMTDATAREP03.chsspokane.local","CHSCITRIXPS06.chsspokane.local","WA1501WDSAPP01.chsspokane.local","WA1501WDSDB01.chsspokane.local","WA1501WTSMRPT01.chsspokane.local","WA1501WSOLDB01.chsspokane.local","WA1501WISTAT1.chsspokane.local","WA1501WTSMRPT1.chsspokane.local","WA1501WPRINT001.chsspokane.local","WA1501WIMO001.chsspokane.local","WA1501NFLOW1.chsspokane.local","WA1501SWAPP1.chsspokane.local","WA1501WNORTEL01.chsspokane.local","WA1501IPLANNET1.chsspokane.local","WA1501WMCTYDB2.chsspokane.local","WA1501WMCTYNX1.chsspokane.local","WA1501WMCTYWCF1.chsspokane.local","WA1501WMCTYMPI1.chsspokane.local","WA1501WMCTYGO1.chsspokane.local","WA1501WMCTYGR1.chsspokane.local","WA1501WMCTYWB1.chsspokane.local","WA1501WMCTYWB2.chsspokane.local","WA1501WMCTYRMI1.chsspokane.local","WA1501WMCTYDB1.chsspokane.local","WA1501WMCTYDBT.chsspokane.local","WA1501WMCTYNXT.chsspokane.local","WA1501WMCTYWCFT.chsspokane.local","WA1501WMCTYMPIT.chsspokane.local","WA1501WMCTYGOT.chsspokane.local","WA1501WMCTYGRT.chsspokane.local","WA1501WMCTYWBT.chsspokane.local","WA1501WMCTYRMIT.chsspokane.local","WA1501WDRF1.chsspokane.local","WA1501WVMCOLL1.chsspokane.local","PATPORTAL-TEST.chsspokane.local","WA1501WRDT001.chsspokane.local","WA1501WR5RDS001.chsspokane.local","WA1501WR5RAS001.chsspokane.local","WA1501WR5RRS001.chsspokane.local","WA1501WHCSAPP001.chsspokane.local","WA1501WHCSSQL001.chsspokane.local","WA1501WNETINV1.chsspokane.local","WA1501WEDCAM001.chsspokane.local","WA1501WGEM001.chsspokane.local","WA1501WDFAPP005.chsspokane.local","CHSCITRIXPS08.chsspokane.local","CHSCITRIXPS09.chsspokane.local","CHSCITRIXPS10.chsspokane.local","CHSCITRIXPS11.chsspokane.local","CHSCITRIXPS12.chsspokane.local","WA1501WVSPDB001.chsspokane.local","WA1501WVSPHR001.chsspokane.local","WA1911WEXTEN001.chsspokane.local","WA1501WNWCT01.chsspokane.local","WA1501WABACUS01.chsspokane.local","WA1501WDB01.chsspokane.local","WA1501WHOME01.chsspokane.local","WA1501W3M01.chsspokane.local","WA1501WVC01.chsspokane.local","WA1501WTMSCS01.chsspokane.local","WA1501WTMSCS02.chsspokane.local"
# $servers | Get-LocalGroupMembership | where name | Export-Csv C:\admin\localadmin_chs.txt