param(
[parameter(Mandatory="True")]
[string] $prefix
)

function Check-Session () {
    try {
        Get-AzureRmContext -ErrorAction Continue
    }
    catch [System.Management.Automation.PSInvalidOperationException] {
        Login-AzureRmAccount
    }
}


function Install-Template {  
param(
    [string] $rg,
    [string] $templateFilePath
)
    # Create or update the resource group using the specified template file and template parameters file
    $rgResult = New-AzureRmResourceGroup -Name $rg -Location "West Europe" -Verbose -Force -ErrorAction Stop 
    return New-AzureRmResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFilePath -siteName $siteName -hostingPlanName $hostingPlanName -Name "InitialDeployment" -Force -Verbose 
}

Check-Session;

$rg = "$prefix-LabRG";
$siteName = "$prefix-arm-webapp";
$hostingPlanName = "$prefix-arm-serviceplan";

Install-Template -rg $rg -templateFilePath .\ARMTemplates\WebSite.json

#Install-Template -rg $rg -templateFilePath .\ARMTemplates\WebSite.json

