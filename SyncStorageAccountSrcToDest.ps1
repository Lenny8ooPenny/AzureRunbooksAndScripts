#Syncs one container from one storage account to another container in a different storage account, within the same subscription.
#Uses a Managed Identity. Can be ran from Hybrid Worker. Will NOT work in Azure Sandbox.
#PowerShell 5.1 used.
#Modules needed: Az.Accounts, Az.Storage, Az Copy

#Authenticate first with your managed identity.
Connect-AzAccount -Identity

#Define source storage account, storage key (stored as encrypted variable in Automation account)
$SourceStorageAcct = ""
$SourceContainer = ""
$SourceStorageKey = Get-AzAutomationVariable -AutomationAccountName "" -Name "" -ResourceGroupName ""
$KeyValueSource = $SourceStorageKey.value
$SourceContext = New-AzStorageContext -StorageAccountName $SourceStorageAcct -StorageAccountKey $KeyValueSource

#Define destination storage account, storage key (stored as encrypted variable in Auomtation account)
$DestinationStorageAcct = ""
$DestinationContainer = ""
$DestinationStorageKey = Get-AzAutomationVariable -AutomationAccountName "" -Name "" -ResourceGroupName ""
$KeyValueDest = $Destination.value
$DestinationContext= New-AzStorageContext -StorageAccountName $DestinationStorageAcct -StorageAccountKey $KeyValueDest

#Executing Syncing between both storage accounts.
"Syncing blobs from Source storage account container to Destination storage account container."
Get-AzStorageBlob -Container $SourceContainer -Context $SourceContext | Start-AzStorageBlobCopy -DestContainer $DestinationContainer -DestContext $DestinationContext
