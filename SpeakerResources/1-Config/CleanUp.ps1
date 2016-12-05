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

Check-Session;

$ask = $true;
$list = Get-AzureRmResourceGroup | Where-Object {$_.ResourceGroupName -ne "myrepository" -and $_.ResourceGroupName -ne "VS-nunos-workshop-Group" -and $_.ResourceGroupName -ne "WorkshopMonitoringRG"}

$list | Select ResourceGroupName |Format-Table

$list |ForEach-Object {
         $skip = $false;

         if ($ask) {
            $invalid = $true;
            while ($invalid) {
                Write-Host "Delete" $_.ResourceGroupName "?";
         
                $command = Read-Host "[Y]es, [N]o, [A]ll";
                switch ($command.ToLower()) {
                    "a" {$ask = $false; $invalid = $false;}
                    "n" {$skip = $true; $invalid = $false;}
                    "y" {$invalid = $false;}
                    default {$invalid = $true}
                }
             
            }
        }
        if (!$skip) {
          Write-Host "Deleting " $_.ResourceGroupName -ForegroundColor Cyan
          Remove-AzureRmResourceGroup -Name $_.ResourceGroupName -Force
        }

    }       
