#REQUIRES -Version 4
#REQUIRES -RunAsAdministrator
#REQUIRES -Modules ActiveDirectory

<#	
	.NOTES
	===========================================================================
	 Version: 1.4.5.2
     Created on:   	3/2/2018
     Modified on:   7/12/2018
	 Author:   	Alberto de la Torre
     Organization: 	Roivant Sciences
     ===========================================================================
	.DESCRIPTION
		New user creation script.  Guided questionaire workflow.
        Updated to work in multiple Vant domains.
        A log is generated and placed in \\rs-ny-nas\shared\it\PowershellOutput\NewHireAccounts.
        Please feel free to contact me with questions, ideas or concerns.

    .HOW TO USE
        Copy and run this script on a domain controller.  Right-click Powershell and "Run as Administrator". 
		Default security groups are imported from respective Vants located in \\rs-ny-nas\shared\IT\Powershell\Scripts\New-VantADUser\Default_Security_Groups
            Create your respective vant CSV if one does not exist.  
            Maintain naming convention as "xxxvant-Consultant.csv" or "xxxvant-Employee.csv"
#>

$LogRoot = "\\rs-ny-nas\shared\it\PowershellOutput\NewHireAccounts"

#Folder path for default security groups
$defaultSGpath = "\\rs-ny-nas\shared\IT\Powershell\Scripts\New-VantADUser\Default_Security_Groups"

###########################################################################################
## DO NOT MODIFY BELOW THIS LINE ##########################################################
###########################################################################################
$localDC = "localhost"

function Get-VantManager {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $ManagerName
    )

    Begin{
        $managerlist = $null

        $managerlist = Get-ADUser -Filter * |Sort-Object name|Where-Object{$_.surname -like "$managername*"}
        if ($($managerlist.count) -gt "1"){
            for ($i = 0; $i -lt $managerlist.Count; $i++) {
                write-host "`t$i - $($managerlist[$i].name)"
            }
            do {
                $SelectManager = Read-Host "Choose manager"
            } until ($SelectManager -ne $null -and $($managerlist[$SelectManager]) -ne $null)

            $script:manager = $($managerlist[$SelectManager])
        } else 
        {
            Write-Host $managerlist.Name
            $script:manager = $managerlist
        }   
    }
}

#Determine logon domain
$localDomain = $(Get-WmiObject win32_computersystem).domain -replace ".local"
$localDomain = $localDomain.Substring(0,1).toupper() +$localDomain.Substring(1).tolower()

#Set employment status and defaults
Write-Host -BackgroundColor DarkGreen -ForegroundColor Yellow "Choose new hire status: "
Write-Host " `
    1 - Consultant
    2 - Employee
"
do
{
    $empStatus = Read-Host "Select number value of status: "
}
until ($empStatus -match '\b[1-2]\b')

switch ($empStatus)
{
    '1' {
        $empOU = "Consultants"
        $SGs = Import-Csv "$defaultSGpath\$localDomain-Consultants.csv"
    }
    '2' {
        $empOU = "Employees"
        $SGs = Import-Csv "$defaultSGpath\$localDomain-Employees.csv"
    }
    Default {}
}

#Set location and defaults
Write-Host -BackgroundColor DarkGreen -ForegroundColor Yellow "Select Location from list below: "
Write-Host " `
    1 - Basel
    2 - Cambridge
    3 - Durham
    4 - Irvine
    5 - NYC - 320 37th Street
    6 - NYC - 11 Times Square
    7 - Phoenix
    8 - San Francisco

"
do
{
    $Location = Read-Host "Select by entering number value of location: "
}
until ($Location -match '\b[1-8]\b')

switch ($Location)
{
    '1' {
        $StreetAddress = "Viadukstrasse 8"
        $City = "4051 Basel"
        $State = ""
        $PostCode = "" 
        $Country = "CH" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\Basel"
    }

    '2' {
        $StreetAddress = "90 Broadway"
        $City = "Cambridge"
        $State = "MA"
        $PostCode = "02142" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\Cambridge"
    }

    '3' {
        $StreetAddress = "324 Blackwell St. Suite 1220, Bay 12"
        $City = "Durham"
        $State = "NC"
        $PostCode = "27701" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\Durham"
    }

    '4' {
        $StreetAddress = "5151 California Avenue, Suite 250"
        $City = "Irvine"
        $State = "CA"
        $PostCode = "92617" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\Irvine"
    }

    '5' {
        $StreetAddress = "320 West 37th Street"
        $City = "New York"
        $State = "NY"
        $PostCode = "10018" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\NYC"
    }

    '6' {
        $StreetAddress = "11 Times Square, 33rd Floor"
        $City = "New York"
        $State = "NY"
        $PostCode = "10036" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\NYC"
    }

    '8' {
        $StreetAddress = "2000 Sierra Point Parkway"
        $City = "Brisbane"
        $State = "CA"
        $PostCode = "94005" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\San_Francisco"
    }

    '7' {
        $StreetAddress = "2398 E. Camelback Rd., Suite 280"
        $City = "Phoenix"
        $State = "AZ"
        $PostCode = "85016" 
        $Country = "US" 
        $Company = "$localDomain Sciences"
        $OULocation = "OU=$empOU,OU=$localDomain Sciences,DC=$localDomain,DC=Local"
        $LogPath = "$LogRoot\Phoenix"
    }
    Default {}
}

# Acquiring unique field data
$GivenName = Read-Host 'Input new users First Name'
$Initial = Read-Host -Prompt 'Input new users middle initial'
$Surname   = Read-Host 'Input new users Last Name'

$alphaonly = '[^a-zA-Z]'
$firstlastname =  $($GivenName.ToLower() -replace $alphaonly) + "." + ($Surname.ToLower() -replace $alphaonly)

do
{
    $empStartDate = Read-Host 'Employee start date.  Enter as MMDD value.'
}
until ($empStartDate -match '\b\d{4}\b' )



$SAMAccountName = $firstlastname
#Samaccount name limited to 20 characters
if ($SAMAccountName.Length -gt 20){
    Write-Output "`nUsername limited to 20 characters"
    $SAMAccountName = $SAMAccountName.Substring(0,20)
}

Write-Verbose "$samaccountname" -Verbose

if(Get-ADUser -Filter "samaccountname -eq '$samaccountname'"){
    Write-Warning "user $samaccountname alread exists"
    #$SAMAccountName = $firstlastname + "." + $Initial.ToLower()
    break
}

$Manager = Read-Host "Enter manager's partial last name. Blank for none."
if ($Manager)
{
    Get-VantManager "$Manager"
    Get-ADUser $Manager.SamAccountName -Properties * -Server $localDC|Select-Object name,samaccountname,OfficePhone,title,department,StreetAddress,State
}

$DisplayName = $GivenName + " " + $Surname
$Title = Read-Host -Prompt 'Input new users title'
$Department = Read-Host -Prompt 'Input new users department'
$Office = $City
$Phone = Read-Host -Prompt 'Input new users phone.555-423-6262   for main office, mobile # for field staff'
$Fax = Read-Host -Prompt 'Input new users fax.555-423-6323   for Main Office'
$Mail = $firstlastname + "@$localDomain.com"
$Description = $Department

$defaultPW = $("$localDomain$" + "$($GivenName.tolower().substring(0,1))" + "$($Surname.tolower().substring(0,1))" + "$empStartDate")

Write-Host -ForegroundColor Yellow -BackgroundColor DarkGreen "`n`nREVIEW INFORMATION"
$UserProperties = @{
    Path = $OULocation
    SamAccountName = $SAMAccountName
    GivenName =  $GivenName
    Initial =  $Initial
    Surname =  $Surname
    Name =  $DisplayName
    DisplayName =  $DisplayName
    EmailAddress =  $Mail
    UserPrincipalName = $Mail
    Title =  $Title
    Description =  $Description
    Enabled =  $true
    ChangePasswordAtLogon =  $false
    PasswordNeverExpires  =  $false
    Fax =  $Fax
    OfficePhone =  $Phone
    Office =  $Office
    Department =  $Department
    StreetAddress =  $StreetAddress
    City =  $City 
    State =  $State 
    PostalCode =  $PostCode  
    Country =  $Country 
    Company =  $Company
    Manager =  $($Manager.samaccountname)
}

$UserProperties|Format-Table

Write-Host -BackgroundColor darkgreen  "----- DEFAULT PASSWORD ------"
    write-host -ForegroundColor Yellow "`t $defaultPW"
    Write-Host -BackgroundColor DarkGreen  "-----------------------------"


Write-Host -BackgroundColor Red "Do you want to proceed?"
$answer = Read-Host "(Y)es or (N)o "

switch ($answer)
    {
        'Y' {
            New-ADUser -Server $localDC -AccountPassword (ConvertTo-SecureString $defaultPW -AsPlainText -Force) @UserProperties

            ## LOGGING #######################
            $UserLogPath = $LogPath + "\$(get-date -format yyyy)\$(Get-Date -Format MMdd)\$SAMAccountName\"

            if (!(Test-Path $UserLogPath))
            {
                New-Item -Path $UserLogPath -ItemType Directory -Force
            }

            $ADCreateLog = "$SAMAccountName-Create_AD.txt"

            "Account created by: $env:USERNAME" |Out-File $("$UserLogPath" + "$ADCreateLog")

            $UserProperties|Format-Table -AutoSize| Out-File $("$UserLogPath" + "$ADCreateLog") -Append
            Get-ADUser -Server $localDC -Identity $SAMAccountName -Properties * |Out-File $("$UserLogPath" + "$ADCreateLog") -Append
            <# Remove default password logging for now
            "DEFAULT PASSWORD: $defaultPW" | Out-File $("$UserLogPath" + "$ADCreateLog") -Append
            #>
            
            #Add Security Group memberships
            foreach ($i in $SGs)
            {
                Add-ADGroupMember -Identity "$($i.Name)" -Members "$SAMAccountName" -Server "$localDC"
            }
            Start-Sleep -Seconds 10
            Get-ADPrincipalGroupMembership -Identity $SAMAccountName |Select-Object name|Sort-Object name |Export-Csv -NoTypeInformation -Path "$("$UserLogPath" + $SAMAccountName + "-GroupMemberships.csv")"
            
            #Final touches
            Write-Host -BackgroundColor DarkGreen "Log Output: $UserLogPath"

        }

        'N' {Write-Host -BackgroundColor Yellow -ForegroundColor Black "User creation cancelled."}
        default {Write-Host -BackgroundColor Yellow -ForegroundColor Black "Invalid answer. User creation cancelled."}
    }