param(
     [Parameter(Mandatory="true")]
     [string] $prefix
)

$resourceGroupName = "$prefix-LabRG";
$webAppName = "$prefix-LabWebApp";
$appServicePlanName = "$prefix-LabServicePlan";

Write-Host;
Write-Host "Checking if Resource Group with name $resourceGroupName already exists" -ForegroundColor Yellow;
$rg = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue;
if (!$rg)
{
    Write-Host "Resource Group name is available" -ForegroundColor Green;
}
else {
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

Write-Host;

Write-Host "Creating Resource Group $resourceGroupName" -ForegroundColor Yellow;
New-AzureRMResourceGroup -Name $resourceGroupName -Location "West Europe";

Write-Host "Creating Service Plan EU-$appservicePlanName" -ForegroundColor Yellow;
New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name "EU-$appservicePlanName" -Tier Free -Location "West Europe";


Write-Host "Creating Service Plan US-$appservicePlanName" -ForegroundColor Yellow;
New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name "US-$appservicePlanName" -Tier Free -Location "Central US";

Write-Host "Creating Web App EU-$webAppName" -ForegroundColor Yellow;
New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name "EU-$webAppName" -AppServicePlan "EU-$appservicePlanName" -Location "West Europe";

Write-Host "Deploying sample web site to EU-$webAppName.azurewebsites.net" -ForegroundColor Yellow
Publish-AzureWebsiteProject -Package .\WebSitePackage\TrafficManagerDemo.zip -Name "EU-$webAppName" 

Write-Host
Write-Host "Creating Web App US-$webAppName" -ForegroundColor Yellow;
New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name "US-$webAppName" -AppServicePlan "US-$appservicePlanName" -Location "Central US";
Write-Host "Deploying sample web site to US-$webAppName.azurewebsites.net" -ForegroundColor Yellow
Publish-AzureWebsiteProject -Package .\WebSitePackage\TrafficManagerDemo.zip -Name "US-$webAppName" 

Write-Host
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