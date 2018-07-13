<#
.NOTES
	===========================================================================
	 Version: 1.1
     Modified on:   3/22/2018
	 Author:   	Alberto de la Torre
	 Organization: 	Roivant Sciences  	
	===========================================================================    

.DESCRIPTION
        For Jeff Swift
        Run this script as is on a domain controller in the domain you want to query.
        Queries all servers in a domain and provides a report of NIC information.
#>

#Output log
$LogPath = "\\rs-ny-nas\shared\it\powershelloutput"


function Get-DNSInfo
{
       [CmdletBinding()]
       [Alias()]
       [OutputType([int])]
       Param
       (
           [Parameter(Mandatory=$true,
                      ValueFromPipelineByPropertyName=$true,
                      Position=0)]
           $Computer
       )
   


      if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) {
       try {
        $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer -EA Stop | Where-Object {$_.IPEnabled}
       } catch {
            Write-Warning "Error occurred while querying $computer."
            Continue
       }

        $domain = $(Get-WmiObject win32_computersystem).domain -replace ".local"

       foreach ($Network in $Networks) {
        $IPAddress  = $Network.IpAddress[0]
        $SubnetMask  = $Network.IPSubnet[0]
        $DefaultGateway = $Network.DefaultIPGateway
        $DNSServers  = $Network.DNSServerSearchOrder
        $WINS1 = $Network.WINSPrimaryServer
        $WINS2 = $Network.WINSSecondaryServer   
        $WINS = @($WINS1,$WINS2)         
        $IsDHCPEnabled = $false
        If($network.DHCPEnabled) {
         $IsDHCPEnabled = $true
        }
        $MACAddress  = $Network.MACAddress


        $OutputObj  = New-Object -Type PSObject
        $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
        $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
        $OutputObj | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask
        $OutputObj | Add-Member -MemberType NoteProperty -Name Gateway -Value ($DefaultGateway -join ",")      
        $OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
        $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value ($DNSServers -join ",")     
        $OutputObj | Add-Member -MemberType NoteProperty -Name WINSServers -Value ($WINS -join ",")        
        $OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress
        $OutputObj |export-csv -Append -NoClobber -NoTypeInformation -Path "$LogPath\dnsinfo-$domain.csv"
        $OutputObj
       }
      }
    }



$Servers = Get-ADComputer -Filter * -Properties operatingsystem,name  |?{$_.operatingsystem -like "*server*"}|select name

$Servers |%{Get-DNSInfo $_.name}