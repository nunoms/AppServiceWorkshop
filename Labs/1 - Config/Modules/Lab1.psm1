function Validate-Lab1 {
    param (
        [parameter(Mandatory="True")]
        [string] $prefix
    )
    $resourceGroupName = "$prefix-LabRG";
    $newAppServicePlanName = "$prefix-StandardWestEurope";
    $webAppName = "$prefix-labwebapp";

    Write-Host;
    $temp = Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $newAppServicePlanName;
    if ($temp -and $temp.GeoRegion -eq "West Europe" -and $temp.Sku.Tier -eq "Standard" -and $temp.Sku.Size -eq "S1" -and $temp.Sku.Capacity -eq 1){
        Write-Host "App Service Plan is correct!" -ForegroundColor Green;
        $temp | Format-Table Name, Location, @{Label="Sku";Expression={$_.Sku.Name}}, @{Label="Instances";Expression={$_.Sku.Capacity}}
    }
    else {
        Write-Host "App Service Plan is not well defined. Try Again..." -ForegroundColor Red
        if ($temp) {
            $temp | Format-Table Name, Location, @{Label="Sku";Expression={$_.Sku.Name}}, @{Label="Instances";Expression={$_.Sku.Capacity}}
        }
    }

    $web = Get-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name $webAppName;
    if ($web -and $web.ServerFarmId -eq $temp.Id) {
        Write-Host "Web App is correct!" -ForegroundColor Green;
        $web | Format-Table SiteName, DefaultHostName, ServerFarmId -Wrap
    }
    else
    {
      Write-Host "Web App is not well defined. Try Again..." -ForegroundColor Red
        if ($web) {
            $web | Format-Table SiteName, DefaultHostName, ServerFarmId -Wrap
        }
    }

}

function Move-WebAppToServicePlan {
param(
	[Parameter(Mandatory=$True)]
    [string] $webAppName
    )

#Get reference to webapp
$webApp = Get-AzureRmWebApp -Name $webAppName;

if (!$webApp)
{
	Write-Host "Invalid WebAppName '$webAppName'. Here is a list of possible values:" -ForegroundColor Red;
	$list = Get-AzureRmWebApp | Sort ResourceGroup;
	$list | Select SiteName, ResourceGroup;
    return;
}

Write-Host;
Write-Host "Found WebApp" $webApp.Name "in location" $webApp.Location -ForegroundColor Green;

#get Resource Group
    $rg = $webApp.ResourceGroup;
	
    $oldServicePlan = Get-AzureRmResource -ResourceId $webApp.ServerFarmId;
    Write-Host "Current Service Plan:" $oldServicePlan.Name "in location" $oldServicePlan.Location -ForegroundColor Green; 

    Write-Host;
    Write-Host "Getting Service Plans in the" $webApp.Location "location and resource group" $rg;
    
    #filtering on both resource group and location to keep isolation during lab
    $list = Get-AzureRmAppServicePlan -ResourceGroupName $rg | Where-Object {$_.Location -eq $oldServicePlan.Location} 
    [System.Collections.ArrayList]$ArrayList = $list;
  
    #remove current plan from list
    $filteredList = $ArrayList | Where-Object {$_.Id -ne $webApp.ServerFarmId}
    Write-Host;
    Write-Host "Please select an option" -ForegroundColor Yellow;
    For ($i=0; $i -lt $filteredList.Length; $i++)
    {
        Write-Host $i "-" $filteredList[$i].Name;
    }
   
    Write-Host $filteredList.Length "- Create a new Service Plan";
    
    $option = Read-Host "Option Number";
    while ($option -gt $filteredList.Length)
    {
        Write-Host "Invalid option..." -ForegroundColor Red;
        $option = Read-Host "Option Number";
    }
    
    Write-Host 

    if ($option -eq $filteredList.Length)
    {
        Write-Host "To create a new service plan, please enter a name." -ForegroundColor Yellow;
        if(!$servicePlanName) {
            $servicePlanName = Read-Host "servicePlanName";
        }

	    Write-Host "Specify a Tier (Free, Shared, Basic, Standard, Premium)" -ForegroundColor Yellow;
    
        if(!$servicePlanTier) {
            $servicePlanTier = Read-Host "servicePlanTier";
        }

        Write-Host "Creating service plan '$servicePlanName' in location" $webApp.Location "using '$servicePlanTier' and Small instance size";
        $servicePlan = New-AzureRmAppServicePlan -Name $servicePlanName -Location $webApp.Location -ResourceGroupName $rg -Tier $servicePlanTier -WorkerSize Small -NumberofWorkers 1;
    }
    else
    {
        $servicePlan = $filteredList[$option];
    }

    Write-Host "Moving app to" $servicePlan.Name -ForegroundColor Green;
    Set-AzureRmWebApp -Name $webAppName -ResourceGroupName $servicePlan.ResourceGroup -AppServicePlan $servicePlan.Name;
}

export-modulemember -function Validate-Lab1
Export-ModuleMember -function Move-WebAppToServicePlan 