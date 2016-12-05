param(
    [parameter(Mandatory="true")]
    [string] $prefix
)

$resourceGroupName = "$prefix-WorkshopDeploymentRG";

Set-StrictMode -Version 3;

function Check-Session () {
    try {
        Get-AzureRmContext -ErrorAction Continue
    }
    catch [System.Management.Automation.PSInvalidOperationException] {
        if (Test-Path c:\1\profile) {
            Select-AzureRmProfile -Path c:\1\profile
        }
        else {
            Login-AzureRmAccount
        }
    }
}


####################
#### SCRIPT BODY
####################

#check if user is already logged in
Check-Session;

Publish-AzureWebsiteProject -Package .\VSApp.zip -Name "$prefix-VS-App" 

Start-Process -FilePath "http://$prefix-VS-APP.azurewebsites.net"