<#
.Synopsis
   This is a script to gather information 

.DESCRIPTION
   This is a basic script designed to gather user and computer information 
   Information gathered includes:
   DNS Name & IP Address
   DNS Server
   Name of Operating System
   Amount of Memory in target computer
   Amount of free space on disk
   Last Reboot of System


.EXAMPLE
   Get-Support
   PS C:\scripts\M5> .\infogather.ps1

    cmdlet infogather.ps1 at command pipeline position 1
    Supply values for the following parameters:
    ComputerName: $ComputerName
    Username: user

    In this example, the script is simply run and the parameters are input as they are mandatory.
.EXAMPLE
   .\infogather.ps1 -ComputerName Client1 -Username user

   This example has mandatory parameters input when calling script.

.EXAMPLE
  .\infogather.ps1 -ComputerName Client1 -Username user | out-file c:\UserInfo.txt

   This example sends the output of the script to a text file.
#>

#infogather.ps1
#Adumbration
#Created: 2022
#Updated: 2022
#Updates: Cleaned up code, removed unused commands
#References: PSHELL Michael Bender

##Paramaters for Computername & UserName
Param (
[Parameter(Mandatory=$true)][string]$ComputerName
)
#Variables
$Credential = Get-Credential
$CimSession = New-CimSession -computername $ComputerName -Credential $Credential
$Analyst = $Credential.UserName
#Commands

#OS Description
   $OS= (Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName).caption

#Disk Freespace on OS Drive 
   $drive = Get-CimInstance -class Win32_logicaldisk | Where-Object DeviceID -EQ 'C:'
   $Freespace = (($drive.Freespace)/1gb)

#Amount of System Memory
   $MemoryInGB = ((((Get-CimInstance Win32_PhysicalMemory -ComputerName $Computername).Capacity|measure -Sum).Sum)/1gb)

#Last Reboot of System
   $LastReboot = (Get-CIMInstance -Class Win32_OperatingSystem –ComputerName $ComputerName).LastBootUpTime      

#IP Address & DNS Name
   $DNS = Resolve-DnsName -Name $ComputerName | Where-Object Type -eq "A" 
   $DNSName = $DNS.Name
   $DNSIP = $DNS.IPaddress 
   $IPInfo = Get-CimInstance Win32_NetworkAdapterConfiguration

#DNS Server of Target
   $DNSServer = (Get-DNSClientServerAddress -cimsession $CimSession -InterfaceAlias "ethernet" -AddressFamily IPv4).ServerAddresses

#Write Output to Screen 
#Clear-Host
Write-Output "Help Desk Support Information for $Computername"
Write-Output "-----------------------------------------------"
Write-Output "Support Analyst: $Analyst";""
Write-output "Computername: $Computername";""
Write-Output "Last System Reboot of $computername : $LastReboot ";""
Write-Output "DNS Name of $computername :$DNSName";""
Write-Output "IP Address of $DNSName : $DNSIP";""
Write-Output "DNS Server(s) for $ComputerName : $DNSServer";""
Write-Output "Total System RAM in $computerName : $MemoryInGB GB";""
Write-Output "Freespace on C:  $Freespace GB";""
Write-Output "Version of Operating System: $OS"

