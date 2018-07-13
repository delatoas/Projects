<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.148
	 Created on:   	2/13/2018 3:05 PM
	 Created by:   	Alberto de la Torre
	 Organization: 	Roivant
	 Filename:     	Remove-DisabledUserGroupMemberships.ps1
	===========================================================================
	.DESCRIPTION
		Search for any disabled user with group memberships.  If found, output memberships to a log then remove.
		Execute this script from either a domain controller or PC with RSAT installed.
#>



$Date = Get-Date -Format MMdd
$DisabledUsers = Get-ADUser -Filter 'enabled -eq $false'

#Change OutputFolder location as desired.
$OutputFolder = "\\rs-ny-nas\shared\it\PowershellOutput\DisabledUser-Cleanup\" + (Get-Date -Format yyyy)

foreach ($u in $disabledusers)
{
    $u.SamAccountName
    $GroupList = $(Get-ADPrincipalGroupMembership "$u"|?{$_.name -notlike "Domain Users" -or $_.name -notlike "*O365*"})
    $userfolder = $OutputFolder +"\"+ (get-date -Format MMdd) +"\"+ $u.UserPrincipalName
    $filename = $userfolder + "\$($u.samaccountname)-GroupMembershipsRemoved.csv"
    
    if ($GroupList)
	{
		#Create user subfolder
        if ($(Get-ChildItem $userfolder -ea SilentlyContinue))
        {}
        else
        {
            Write-Host "Create folder $userfolder"
            New-Item -ItemType Directory $userfolder -Force
        }
		
		# MEAT of script.  Remove-ADGroupmember
        $GroupList |%{Remove-ADGroupMember -Identity "$($_.samaccountname)" -Members "$($u.SamAccountName)" -Confirm:$false}
		
		# Export list
        $GroupList|Export-Csv $filename -NoTypeInformation -NoClobber
    }
}