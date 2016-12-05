#how to get help
get-help Get-AzureRmResourceGroup
get-help Get-AzureRmResourceGroup -full
get-help foreach -full

#taking care of basics
$prefix = "<your-prefix-here>";
$resourceGroupName = "$prefix-LabRG";
$USServiceplan = "US-$prefix-LabServicePlan";
$EUServicePlan = "EU-$prefix-LabServicePlan";

############################
#   RUN INITIALIZE SCRIPT
############################
.\Initialize.ps1 -prefix $prefix

#Get list of Resource Groups
Get-AzureRmResourceGroup
Get-AzureRmResourceGroup | Format-Table ResourceGroupName, Location

#Get just your Resource Group
Get-AzureRmResourceGroup -Name $resourceGroupName

#Get list of App Service Plan in a resource group
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName | Select Name, Location, NumberOfSites

#get a single app service plan
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $EUServicePlan

#drill down inside an object
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $EUServicePlan | Select Sku
(Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $EUServicePlan).Sku

#storing an object in a variable
$servicePlan = Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $EUServicePlan;
Write-Host $servicePlan.Name "is a" $servicePlan.Sku.Tier $servicePlan.Sku.Size "service plan hosted in" $servicePlan.GeoRegion -ForegroundColor Green

#expanding properties on a pipeline operation
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName | Format-Table Name, Location, {$_.Sku.Name}
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName | Format-Table Name, Location, @{Label="Sku";Expression={$_.Sku.Name}}, @{Label="Instances";Expression={$_.Sku.Capacity}}

#######################
###    CHALLENGE    ###
#######################

#Create new Web App inside your ResourceGroup on the EUServicePlan
#use the following for web app name
$webAppName = "$prefix-labwebapp";

#Answer goes here (Hint: it starts with New-AzureRm...)


#list all web apps
Get-AzureRMWebApp -ResourceGroupName $resourceGroupName | Format-Table SiteName, DefaultHostName, ServerFarmId -Wrap

#get a reference to our new web App and expand to get hosting service plan
$temp = Get-AzureRMWebApp -ResourceGroupName $resourceGroupName -Name $webAppName | Get-AzureRmResource -ResourceId {$_.ServerFarmId}

#######################
###    CHALLENGE    ###
#######################

#Create new App Service Plan inside your ResourceGroup
#Location: West Europe
#Tier: Standard
#VM Size: small
#VM Count: 1

#Use $newAppServicePlanName as the name for the new App Service Plan
$newAppServicePlanName = "$prefix-StandardWestEurope";

#Answer goes here (Hint: it starts with New-AzureRm...)


####################################

#list all App Service Plans (repeat)
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName | Format-Table Name, Location, NumberOfSites

#Get Empty App Service Plans
Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName | Where-Object {$_.NumberOfSites -eq 0} | Format-Table Name, Location

#get web apps in a service plan
$servicePlan = Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $EUServicePlan
Get-AzureRmWebApp -AppServicePlan $servicePlan | Format-Table SiteName, State, DefaultHostName


#######################
###    CHALLENGE    ###
#######################

#move web app to the new service plan
#remember the variables where names are stored:
$webAppName = "$prefix-labwebapp";
$newAppServicePlanName = "$prefix-StandardWestEurope";

#Answer goes here (Hint: Starts with Set-AzureRm...)


#Check your results: get list of apps in new AppServicePlan
$servicePlan = Get-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $newAppServicePlanName
Get-AzureRmWebApp -AppServicePlan $servicePlan | Format-Table SiteName, State, DefaultHostName

#Let's check the result for the whole lab:
Import-Module .\Modules\Lab1.psm1
Validate-Lab1 -prefix $prefix;


#using fancy scripts - optional
$temp = "$prefix-testwebapp";
New-AzureRmWebApp -Name $temp -ResourceGroupName $resourceGroupName -Location "West Europe"
#choose option to create new service plan and remember the name (used in the next step)
Move-WebAppToServicePlan $temp
#remove service plan here
Remove-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name $temp
Remove-AzureRmAppServicePlan -Name nunos-testplan -ResourceGroupName $resourceGroupName -Force


#setting app settings - monitor with Fiddler if you can
$appSettings = @{
     "Location" = "EUROPE"; 
 };

$updatedApp = Set-AzureRMWebApp -ResourceGroupName $resourceGroupName -Name $webAppName -AppSettings $appSettings;



#for traffic manager demo - scaling up service plans
Set-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $EUServicePlan -Tier Standard -WorkerSize Small
Set-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $USServicePlan -Tier Standard -WorkerSize Small

#clean up everything
Remove-AzureRmResourceGroup -Name $resourceGroupName -Force