########################################################
#                Get-HyperVInventory                   #
# version: v2.4-170222                                 #
# authors:  Christopher Junker, Nils Kaczenski,        #
#           Sascha Loth                                #
# company: Michael Wessel Informationstechnologie GmbH #
# mail:    cju@michael-wessel.de                       #
# phone:   0511 260 911 0                              #
# date:    11|11|2015                                  #
########################################################

OVERVIEW:
Get-HyperVInventory.ps1 is a PowerShell script to create documentation reports (plain text) of single Hyper-V host servers or complete Hyper-V failover clusters.
It should work with Windows Server 2012 and later and with client Hyper-V on Windows 8 and later.
Get-HyperVInventory reads configuration data from Hyper-V host servers and writes them to a plain text file in a structured way. It is designed to be an inventory and reporting tool. It does not include performance or health data.
The script does not change anything on the systems. It only reads data and writes a text file. Thus, it is not "harmful" by itself.
It may, however, create significant load on your host servers if you run it in a very large environment.
The reports may include confidential data. So you should make sure to handle the reports adequately.
The script has multiple operation modes that let you choose between a full cluster inventory (including all host servers and all VMs), an inventory of just the local host server (including or excluding all VMs), a cluster core inventory or VM inventories. 

LICENSE:
The script is free. You may alter it and redistribute it as you like.
We ask you, however, to keep a hint on the original author(s) in your source code.
Neither the author nor the company can provide any warranty for the script and will accept no liability. Use at your own risk. Support will only be granted for payment.

FEATURES:
This is only a small compilation of the data the script gathers:
- Hyper-V failover clusters: cluster core data, cluster networks, cluster storage
- Hyper-V host servers: OS details, CPUs (and cores), RAM, host networking, virtual switches, replication
- VMs: general data, CPU, RAM, networking, disks, Integration Services, replication

ATTENTION:
This script has not been designed for very large environments. It has not yet been tested in large environments, either.
As the script may create significant load (especially when there are many hosts in a cluster) please make sure that its execution will not harm your production environment.
You can always run the script in "singleHost" mode to test it or to gather data from individual hosts. This should not have much impact on the respective server.
But keep in mind that you need to run the script with Administrator privileges so make sure that the script has not been modified by an attacker.
Neither the author nor the company can provide any warranty for the script. Use at your own risk. Support will only be granted for payment.

PREREQUISITES:
This script has been developed on Windows Server 2012 R2 and Windows Server 2016.
You need:
- OS: Windows Server 2012, Windows Server 2012 R2 or Windows Server 2016, any edition capable of Hyper-V
  (limited functionality in Windows Server 2012)
  Client Hyper-V on Windows 8 and later
- PowerShell 3.0 or higher (default in Windows Server 2012, v4.0 in 2012 R2)
- Hyper-V role installed and configured
- optional: Failover cluster role installed and configured
- Run the script on a PowerShell session with elevated privileges. Your account needs Administrator privileges on each host to report on.
- a folder to store the report (default: current user's Documents folder, but you can specify any folder)

USAGE:
./Get-HyperVInventory.ps1 [-output <string>] [-mode <string>] [-noview <boolean>]

PARAMETERS:
-output (str) - optional
	Define where Get-HyperVInventory.ps1 writes its output. To do so, specify the parameter -output with complete filepath with extension.
	Example:
		-output "C:\some\path\to\your\file.txt"
	If you leave this parameter out the script will generate a filename with a timestamp and store it in the current user's Documents folder.

-mode (str) - optional
	Specify the script's mode. Currently there are five modes:
	  ClusterFullInventory - tries to identify the failover cluster that the local host belongs to and then to get complete information on the cluster, on each host, and on all VMs placed on each host.
		If the host is not part of a cluster (or it cannot identify it) the script will automatically switch to SingleHost mode.
	  LocalHostInventory - creates a report of the local host only, including information on all VMs placed on it.
	  ClusterOnlyInventory - creates a report of the cluster configuration only, without host and VM details.
	  VMInventoryCluster - creates a report of all VMs in the cluster and all non-clustered VMs on each host.
      VMInventoryHost - creates a report of all VMs on the local host.
	Example:
	  -mode LocalHostInventory
	If you leave this parameter out the script will start with a manual selection of the modes. So to fully automate the inventory process you need to specify the mode.

-format (str) - optional
	Specify the format for the report file. There is a choice of two:
	  HTML - creates a report file in HTML format, good to read and compatible with all browsers. This might, however, result in a very large file for full inventories.
    TXT - creates a report file in plain text format. The file size is smaller but the output may be harder to read.
	Example:
	  -format TXT
	If you leave this parameter out the script will create an HTML file.

-noview (bool) - optional
	Specify if you want to suppress the automatic display of the created report file. Set -noview $true if you do NOT want to open the report.
	Example:
	  -noview $true
	If you leave this parameter out or set it to $false the report file will be opened in your default text editor at the end of the script's execution. For full automatization you will want to suppress this.

IMPORTANT NOTES: 
- Set your PowerShell Execution Policy to "RemoteSigned" at least. Depending on where your copy is stored you might need to set it to "Unrestricted".
  Example: 'Set-ExecutionPolicy RemoteSigned'
- Run the script like this in the powershell commandshell: ./Get-HyperVInventory.ps1 [-output <string>] [-mode <string>] [-noview <boolean>]
- Run the script locally on the Hyper-V host server that you want to report on (or on one of the cluster hosts of the cluster you want to document).
- If you encounter any bugs, or have got an idea on how to improve the script, please report to cju@michael-wessel.de

MODES: supported modes in the current version:
- ClusterFullInventory: Allows you to inventory a full failover-cluster system, including host and VM details (this is the most complete report)
- LocalHostInventory: Allows you to inventory a single host, including VM details (the machine on which the script is beeing called)
- ClusterOnlyInventory: Allows you to inventory only the cluster as such, without details on the hosts and the VMs
- VMInventoryCluster: Allows you to inventory all VMs in the cluster as well as all non-clustered VMs on each host
- VMInventoryHost: Allows you to inventory all VMs on the local host
- Host Full Inventory (reports one single host with its VMs)
- Single VM Inventory (reports one single VM on a specified host)
- Host-only Inventory now both for local and remote hosts
- VM-only Inventory now both for local and remote hosts

CHANGES:
2.4
	- new data included:
		- Shielded VM config per VM
		- VM Groups
		- Checkpoint type
		- Host Resource Protection
		- Nested Virtualization per VM
		- VM cluster Start Order Priority and Cluster Group Sets
		- virtual Fibre Channel settings (thanks to Sascha Loth)
		- Switch-embedded Teaming
	- bug fixes		
2.3
	- new data included:
		- host OS installation date
		- host active Power Plan
		- host system serial number
		- host iSCSI sessions and connections
		- host volume partition info
		- VM replication frequency
		- CAU availability
	- report title in HTML title tag
	- vSwitch bandwidth default settings labeled more clearly
	- added companion script Get-HyperVInventory-MultipleReports.ps1 to create separate reports automatically
2.2
	- bandwidth reservation settings for host vNICs and vSwitches
	- cluster-wide summary of vRAM and vCPU assignments
	- NUMA settings per host
	- new report modes: 
		- Host Full Inventory (reports one single host with its VMs)
		- Single VM Inventory (reports one single VM on a specified host)
		- Host-only Inventory now both for local and remote hosts
		- VM-only Inventory now both for local and remote hosts
	- parameter validation for -mode and -format
	- all reports can be launched by menu; script will ask for necessary values
	- Known issue: disk cluster size does not report correctly in Windows Server 2016 TP2
	- Known issue: Report will not open automatically in Edge browser for builtin Administrator
2.1
	- corrected version check for local host (now works with builds above 10000)
	- corrected gathering of Cluster-VM list
	- host network details: default gateway, DNS servers
	- VM network identifies legacy NICs
	- Host VMQ ability
	- disk cluster sizes for host volumes and CSV volumes
	- sum of VM memory and vCPUs per host
	- Guest OS name, FQDN and IS version for VMs (if running Windows)
	- added counts for various object types
	- checks for the number of updates on each host
	- checks for the presence of KB3046359 if applicable, warns if not installed
	- report layout extended
	- Known issue: disk cluster size does not report correctly in Windows Server 2016 TP2
	- Known issue: Report will not open automatically in Edge browser for builtin Administrator
2.0	- major release
	- minor changes, cosmetical only
1.2
	- bug fixed: when a VM in a cluster had a cluster object name that was different from the VM name the script would run into an error
	- consolidated to functions into one
1.1
	- changed some code to make it client-compatible
	- cluster network roles
	- Live Migration networks on cluster level
	- most object collections now appear sorted (mostly by name)
	- tidied up the code a bit
1.0
	- first public release
0.89
	- additional CSV info
	- additional NIC teaming info
	- check for existing administrator privileges
	- removed checkpoint type again because Production Checkpoints can not yet be easily identified via PowerShell
0.85
	- corrected replica connections for clusters with no Replica Broker
	- Cluster roles (groups)
	- several smaller corrections
0.83
	- host Hyper-V config info
	- VMconnect access info for VMs
	- Replica settings for host and VMs
	- members of Hyper-V Administrators
	- Help included in PowerShell help format
0.82
	- add: host storage info
	- add: VM checkpoint info
0.81
	- corrections and additions
0.8
	- additional data for the reports
	- improved cluster test
	- new location and format for the report file name
	- command-line integration for script mode and report view
0.7
	- Script now lets you choose which mode to call
	- Added Function to test if Failover-Cluster feature is installed
	- Added shell support