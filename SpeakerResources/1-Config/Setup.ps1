param(
     [Parameter(Mandatory="true")]
     [string] $prefix,
     [switch] $CleanUp
)

$resourceGroupName = "WorkshopIntroRG";
$webAppName = "$prefix-DemoWebApp";
$appServicePlanName = "Workshop-ServicePlan";
$otherWebAppName = "$prefix-DemoBackoffice";

################################
#### FUNCTION DECLARATIONS
################################

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

function RemoveResourceGroup {
    Write-Host "Removing Resource Group $resourceGroupName..." -NoNewline -ForegroundColor Yellow;
    $result = Remove-AzureRmResourceGroup -Name $resourceGroupName -Force;
    if ($result)
    {
        Write-Host "Completed"  -ForegroundColor Green;
    }
    else {
        Write-Host "Failed" -ForegroundColor Red;
        exit;
    }
}

################################
#### SCRIPT BODY STARTS HERE
################################

#check if user is already logged in
Check-Session;

if ($CleanUp)
{
    $rg = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue;
    if (!$rg) {
         Write-Host "Resource Group name doesn't exist." -ForegroundColor Green;
    }
    else {
        RemoveResourceGroup; 
    }
    exit;
}

Write-Host;
Write-Host "Checking if Resource Group with name $resourceGroupName already exists" -ForegroundColor Yellow;
$rg = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue;
if (!$rg)
{
    Write-Host "Resource Group name is available" -ForegroundColor Green;
}
else {
  RemoveResourceGroup;
}

Write-Host;

Write-Host "Creating Resource Group $resourceGroupName" -ForegroundColor Yellow;
New-AzureRMResourceGroup -Name $resourceGroupName -Location "West Europe";

Write-Host "Creating Service Plan EU-$appservicePlanName" -ForegroundColor Yellow;
New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name "EU-$appservicePlanName" -Tier Standard -WorkerSize Small -Location "West Europe";

Write-Host "Creating Service Plan US-$appservicePlanName" -ForegroundColor Yellow;
New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name "US-$appservicePlanName" -Tier Standard -WorkerSize Small -Location "Central US";

Write-Host "Creating Web App EU-$webAppName" -ForegroundColor Yellow;
New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name "EU-$webAppName" -AppServicePlan "EU-$appservicePlanName" -Location "West Europe";
Publish-AzureWebsiteProject -Package .\WebSitePackage\TrafficManagerDemo.zip -Name "EU-$webAppName"

Write-Host "Creating Web App US-$webAppName" -ForegroundColor Yellow;
New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name "US-$webAppName" -AppServicePlan "US-$appservicePlanName" -Location "Central US";
Publish-AzureWebsiteProject -Package .\WebSitePackage\TrafficManagerDemo.zip -Name "US-$webAppName"

Write-Host "Creating Web App $otherWebAppName" -ForegroundColor Yellow;
New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name $otherWebAppName -AppServicePlan "EU-$appservicePlanName" -Location "West Europe";

Write-Host "Setting up configuration on websites" -ForegroundColor Yellow

$appSettings = @{
     "Location" = "US"; 
 };

$updatedApp = Set-AzureRMWebApp -ResourceGroupName $resourceGroupName -Name "US-$webAppName" -AppSettings $appSettings;

$appSettings = @{
     "Location" = "EUROPE"; 
 };

$updatedApp = Set-AzureRMWebApp -ResourceGroupName $resourceGroupName -Name "EU-$webAppName" -AppSettings $appSettings;


Write-Host;
Write-Host "All Actions Completed" -ForegroundColor Green;
