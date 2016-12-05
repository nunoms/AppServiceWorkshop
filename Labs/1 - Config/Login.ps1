#login to Azure
Login-AzureRmAccount;

#prevent script from running
exit;

#get list of subscriptions assigned to this account
Get-AzureRmSubscription

#insert the correct subscriptionId here
Select-AzureRmSubscription -SubscriptionId $subscriptionId;

#check the new status
Get-AzureRmContext;

#if happy save the profile
md C:\1
Save-AzureRmProfile -Path C:\1\profile

#from now on just do this
Select-AzureRmProfile -Path c:\1\profile