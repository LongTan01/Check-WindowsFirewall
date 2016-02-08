################################################################
# SCRIPT: Check-WindowsFirewall.ps1
# AUTHOR: Josh Ellis - Josh@JoshEllis.NZ
# Website: JoshEllis.NZ
# VERSION: 1.0
# DATE: 08/02/2016
# DESCRIPTION: Checks if the Windows Firewall is enabled on a remote server.
################################################################


$ServerList = Get-ADComputer -Filter {OperatingSystem -like '*windows*Server*'} | Select -ExpandProperty Name
$MasterList = $null
$MasterList = New-Object -TypeName System.Collections.ArrayList

Foreach ($Server in $ServerList)
    {

    #Test Connection and run tests
    if((Test-Connection -Quiet $Server) -eq 'True')
        {
        $ServerOnline = 'Online'
        $HKLM = 2147483650
	$reg = get-wmiobject -list -namespace root\default -computer $Server | where-object { $_.name -eq "StdRegProv" }
	$DomainFirewall = $reg.GetDwordValue($HKLM, "System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile","EnableFirewall")
        $PrivateFirewall = $reg.GetDwordValue($HKLM, "System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile","EnableFirewall")
        $PublicFirewall = $reg.GetDwordValue($HKLM, "System\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile","EnableFirewall")

        #Results
        $DomainFirewallResult = [bool]$DomainFirewall.uvalue
        $PrivateFirewallResult = [bool]$PrivateFirewall.uvalue
        $PublicFirewallResult = [bool]$PublicFirewall.uvalue
        }
        else {
             $ServerOnline = 'Offline'
             $DomainFirewallResult = "N/A"
             $PrivateFirewallResult = "N/A"
             $PublicFirewallResult = "N/A"
             }

    #Log Results
    $ServerResults = New-Object -TypeName psobject -Property @{
        ServerName = $Server;
        Online = $ServerOnline;
        DomainFirewall = $DomainFirewallResult;
        PrivateFirewall = $PrivateFirewallResult;
        PublicFirewall = $PublicFirewallResult
        }
    [VOID]$MasterList.Add($ServerResults)
    }

$MasterList | Select ServerName,Online,DomainFirewall,PrivateFirewall,PublicFirewall | Sort ServerName | Format-Table 
