write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
Write-Host -ForegroundColor Yellow " Custom Vant powershell commands loaded " 
Write-Host -ForegroundColor Yellow " Please use Connect-VantExchangeOnline to open a session with Azure and O365 Exchange"
write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

Import-Module \\rs-ny-nas\shared\it\Powershell\AzureAD_Module\AzureADPreview.psd1

<#
.Synopsis
   Connect to Vant Exchange Online
.DESCRIPTION
   Connect to Vant Exchange Online.  This is a quicker way to connect online rather than having to constantly typing your long winded username.
.SYNTAX
   Connect-VantExchangeOnline
.EXAMPLE
   Just type "Connect-VantExchangeOnline", all you have to do is enter your username and your MFA code.
#>
function Connect-VantExchangeOnline
{

    Connect-EXOPSSession -UserPrincipalName $o365cred
    Connect-AzureAD -AccountId $o365cred

}



<#
.Synopsis
   Lookup mailbox folder policies
.DESCRIPTION
   Lookup mailbox folder policies.

.EXAMPLE
   Get-VantMailFolderPolicies $username

.EXAMPLE
   PS C:\> Get-VantMailFolderPolicies darcy.thornell

    Name           FolderPath         DeletePolicy
    ----           ----------         ------------
    darcy.thornell /#BUSINESS RECORDS Never Delete
    darcy.thornell /#WORKING          3 Year Delete
#>
function Get-VantMailFolderPolicies
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Enter username
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Username
    )

    $Username | % {

        Get-MailboxFolderStatistics -Identity $_ |?{$_.folderpath -like "*#working*" -or $_.folderpath -like "*#business records*"}|select @{n="Name";e={$_.identity -replace '\\.*'}},folderpath,deletepolicy

        }
}

<#
.Synopsis
   Lookup folder permissions
.DESCRIPTION
   Lookup folder permissions
.EXAMPLE
   Get-VantFolderPermission "\\rs-ny-nas\Shared"
    
    FileSystemRights  : Modify, Synchronize
    AccessControlType : Allow
    IdentityReference : NT AUTHORITY\Authenticated Users
    IsInherited       : False
    InheritanceFlags  : ContainerInherit, ObjectInherit
    PropagationFlags  : None

#>
function Get-VantFolderPermission
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Path
    )

    Get-Acl $Path |select -ExpandProperty access

}



function Get-VantUserGroupMemberships
{
    param(
    # Parameter help description
    $username
    )

    Get-ADPrincipalGroupMembership $username |Sort-Object name|Select-Object name,samaccountname

}