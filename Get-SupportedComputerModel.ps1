<#
.SYNOPSIS
    Gets a list of supported computer models via SCCM via SCConfigMgr WebService. 
.DESCRIPTION
    Queries SCCM via SCConfigMgr WebService to create a list of computers with drivers managed
    by SCConfigMgr.com Modern Driver Management.  This is then ouput to a text file for use with
    SCConfmgr.com's ConfigMgr OSD FrontEnd.
.PARAMETER URI
    Mandatory [string] URI identifying the SCConfigMgr WebService.
.PARAMETER SecretKey
    Mandatory [string] Secret key necessary for accessing the WebService.
.PARAMETER PilotDrivers
    Optional [switch] If included the pilot drivers will be retrieved in place of the production
    drivers.  It's doubtful this will ever be used, but better to have it and not need it, right?
.PARAMETER Destination
    Mandatory [string] Path\Filename where the output should be stored.  If this is being used to 
    feed ConfigMgr OSD Frontend, the destination will be HWModels.txt on the WebService server.
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    VERSION 1.1.0
        Creation Date: 2019-09-30
        Author: John Trask
        Purpose/Change(s):
            Added Param block rather than hardcoding everything.
    VERSION 1.0.0
        Creation Date: 2019-09-27
        Author: John Trask
        Purpose/Change(s):
            Added Param block rather than hardcoding everything.
            
    This is a Dell shop with a smattering of HP systems.  If support for other manufactureres is needed, 
    the ForEach loop will need to be modified accordingly.
.EXAMPLE
    PS> Get-SupportedComputerModel.ps1 -URI 'http://CMSERVER.company.local/ConfigMgrWebService/ConfigMgr.asmx' -SecretKey '1c83bfeb-8c32-49df-866b-a33e896c5f83' -Destination '\\CMSERVER\C$\Inetpub\ConfigMgr WebServer\HWModel.txt'

    Generates a list of MDM-supported computer models and creates/replaces the HWModels.txt file on the WebService server.

.EXAMPLE
    PS> Get-SupportedComputerModel.ps1 -URI 'http://CMSERVER.company.local/ConfigMgrWebService/ConfigMgr.asmx' -SecretKey '1c83bfeb-8c32-49df-866b-a33e896c5f83' -Destination '\\CMSERVER\C$\Inetpub\ConfigMgr WebServer\HWModel.txt' -PilotDrivers

    Generates a list of for MDM-supported computer models with 'pilot' drivers and creates/replaces the WHModels.txt file on the WebService server.
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)]
    [string]$URI,

    [Parameter(Mandatory=$True)]
    [string]$SecretKey,

    [Parameter(Mandatory=$True)]
    [string]$Destination,
    
    [Parameter(Mandatory=$False)]
    [Switch]$PilotDrivers
)

$Web = New-WebServiceProxy -Uri $URI

If ($PilotDrivers) {
    $Filter = 'Drivers Pilot - %'
}
Else {
    $Filter = 'Drivers - %'
} 

$PackageNames = ($Web.GetCMPackage($SecretKey,$Filter)).PackageName

[system.Collections.ArrayList]$Models = @()
ForEach ($PackageName in $PackageNames) {
    $Model = ($PackageName -split ' - ')[1]
    $Model = $Model.Replace('Dell ','')
    $Model = $Model.Replace('Hewlett-Packard ','')
    $Models.Add($Model) | Out-Null
}

$Models | Out-File -FilePath $Destination -Force
