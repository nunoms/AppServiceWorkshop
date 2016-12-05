param(
    [parameter(Mandatory="true")]
    [string] $prefix
)

$resourceGroupName = "$prefix-WorkshopMonitoringRG";

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

function InstallTemplate {  
param(
    [string] $rg
)
    # Create or update the resource group using the specified template file and template parameters file
    $rgResult = New-AzureRmResourceGroup -Name $rg -Location "West Europe" -Verbose -Force -ErrorAction Stop 
    return New-AzureRmResourceGroupDeployment -prefix $prefix -ResourceGroupName $rg -TemplateFile .\azureDeploy.json -Name "InitialDeployment" -Force -Verbose 
}

####################
#### SCRIPT BODY
####################

#check if user is already logged in
Check-Session;

InstallTemplate -rg $resourceGroupName;

Publish-AzureWebsiteProject -Package .\BuggyAppFinal.zip -Name "$prefix-mybuggywebsite"
Publish-AzureWebsiteProject -Package .\BuggyAppFinal.zip -Name "$prefix-mybuggywebsite" -Slot "Staging"

Start-Process -FilePath "http://$prefix-mybuggywebsite.azurewebsites.net"