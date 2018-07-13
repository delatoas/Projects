<#
.Synopsis
   AD account off-boarding
.DESCRIPTION
   Vant AD account off-boarding
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.NOTES
    =================================================================
        Version .1 Beta
        Modified: 03/24/2018
        Author: Alberto de la Torre
        Organization: Roivant Sciences
    =================================================================
#>

function Remove-VantADUser {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        $VantUsername
    )
    $testLocalDC = Get-ADDomainController

    $dadmin = get-credential -Message "Provide domain admin account"
 
        try {
            $VantADUser = Get-ADUser $VantUsername -Properties * -ErrorAction SilentlyContinue
        }
        catch {
            Write-Output $VantUsername + " not found."
        }
    
    $LogFolder = "\\rs-ny-nas\shared\it\PowershellOutput\OffBoarding"
    $userfolder = "$VantUsername"

    $FutureDeleteDate = $(get-date).adddays(120).ToString('MM-dd-yyyy')
    $Date = Get-Date -Format yyyyMMdd

    #Determine logon domain
    $localDomain = $(Get-WmiObject win32_computersystem).domain -replace ".local"
    $localDomain = $localDomain.Substring(0,1).toupper() +$localDomain.Substring(1).tolower()

    Write-Host -BackgroundColor Red "`tGoto Okta, Disconnect account from AD and hide from GAL..."
    Pause
    
    Disable-ADAccount -Identity $VantUsername -Credential $dadmin
    Set-ADUser -Identity $VantUsername -Description "Delete on $FutureDeleteDate" -Credential $dadmin
    
    $GroupList = $(Get-ADPrincipalGroupMembership "$VantUsername"|?{$_.name -notlike "Domain Users" -or $_.name -notlike "*O365*"})
    if ($GroupList)
	{
		#Create user subfolder
        if ($(Get-ChildItem $userfolder -ea SilentlyContinue))
        {}
        else
        {
            New-Item -ItemType Directory "$LogFolder\$userfolder" -Force
        }
		
        $GroupList |%{Remove-ADGroupMember -Identity "$($_.samaccountname)" -credential $dadmin -Members "$VantUsername" -Confirm:$false}
		
		# Export list
        $GroupList|Export-Csv "$logfolder\$date\$userfolder\GroupMemberships.csv" -NoTypeInformation -NoClobber
    }



    

}