$resourceGroupName = "ContactManagerResourceGroup";

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
    return New-AzureRmResourceGroupDeployment -ResourceGroupName $rg -TemplateFile .\contactManagerTemplate.json -TemplateParameterFile .\contactManager.parameters.json -Name "InitialDeployment" -Force -Verbose 
}

function SetupBackupSchedule {
param(
[string] $rg,
[string] $storageAccountName,
[string] $appName    
)
       
        # This returns an array of keys for your storage account. Here we select the first key as a default.
        $storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $storageAccountName
        $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey[0].Value

        #define backup container
        $blobContainerName = "backups";
   
        # Create container on the new storage account
        $temp = New-AzureStorageContainer -Name $blobContainerName -Context $context -ErrorAction SilentlyContinue

        #get SAS token    
        $sasUrl = New-AzureStorageContainerSASToken -Name $blobContainerName -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddMonths(1) -FullUri

        #get connections string from database
        $webApp = Get-AzureRmWebApp -Name $appName -ResourceGroupName $rg
        $connString = $webApp.SiteConfig.ConnectionStrings[0];

         #configure backup to include SQL
        $dbSetting1 = New-AzureRmWebAppDatabaseBackupSetting -Name ContactManagerDb -ConnectionStringName ContactManagerDb -DatabaseType SQLAzure -ConnectionString $connString.ConnectionString
    
        #do first backup
        $backup = New-AzureRmWebAppBackup -ResourceGroupName $rg -Name $appName -BackupName "AfterDeployment" -StorageAccountUrl $sasUrl -Databases $dbSetting1 
        #create a schedule
        $temp = Edit-AzureRmWebAppBackupConfiguration -Name $appName -ResourceGroupName $rg -FrequencyInterval 1 -FrequencyUnit "Day" -StorageAccountUrl $sasUrl -Databases $dbSetting1 -KeepAtLeastOneBackup -StartTime (Get-Date).AddHours(1) -RetentionPeriodInDays 5
         Write-Host "Configured Backup" -ForegroundColor Green;
}

####################
#### SCRIPT BODY
####################

#check if user is already logged in
Check-Session;

$result = InstallTemplate -rg $resourceGroupName;

if ($result.ProvisioningState -eq "Succeeded") {
    
    # get outputs from template deployment
    $storageAccountName = $result.Outputs["storageAccountName"].Value;
    $appName = $result.Outputs["webSiteName"].Value;
    $siteUri = $result.Outputs["siteUri"].Value;

    Write-Host
    Write-Host "Waking up website..." -ForegroundColor Yellow -NoNewline
    $webResult = Invoke-WebRequest -Uri "http://$siteUri"

    if ($webResult.StatusCode -eq 200){
        Write-Host "Completed!" -ForegroundColor Green
        SetupBackupSchedule -rg $resourceGroupName -storageAccountName $storageAccountName -appName $appName;
    }
    else {
        Write-Host "Error!" -ForegroundColor Red;
        $webResult;
    }

    
}
else {
    Write-Host
    Write-Host "Errors deploying template. Aborting..." -ForegroundColor Red;
    $result
}
