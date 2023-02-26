#Exports an Azure SQL Database as a .bacpac file to a storage account over private links, automatically approving the private endpoint connections.

Connect-AzAccount -Identity
$AzureContext = Set-AzContext -SubscriptionId "#####################"

$ResourceGroupName = ""
$ServerName = ""
$DatabaseName = ""
$StorageKeytype = "StorageAccessKey"
$StorageKey = "###########################################################=="
$BacpacUri = "https://storage.blob.core.windows.net/test/test1.bacpac"
$storageResourceForPrivateLink = "/subscriptions/###################/resourceGroups/Test-Storage/providers/Microsoft.Storage/storageAccounts/teststorageacclk"
$sqlResourceForPrivateLink = "/subscriptions/#######################/resourceGroups/Test-VMs/providers/Microsoft.Sql/servers/testlk"

#Should store credentials as encrypted credentials in Automation Account. Otherwise, you can use the following too.
$PlainPassword = ""
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

#Starts the export process.
$exportRequest = New-AzSqlDatabaseExport -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName -StorageKeytype $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri -AdministratorLogin "Adminuser" -AdministratorLoginPassword $SecurePassword -UseNetworkIsolation $true -StorageAccountResourceIdForPrivateLink $storageResourceForPrivateLink -SqlServerResourceIdForPrivateLink $sqlResourceForPrivateLink

#Include delay as it does take some time.
Start-Sleep -Seconds 30

## Approve the Private Endpoint Connection for the Storage Account
$storagePrivate_Endpoint_Connection_Resource = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $storageResourceForPrivateLink | Where-Object {($_.PrivateEndpoint.Id -like "*ImportExportPrivateLink_Storage*" -and $_.PrivateLinkServiceConnectionState.status -eq "Pending")}
Start-Sleep -Seconds 30
Approve-AzPrivateEndpointConnection -ResourceId $storagePrivate_Endpoint_Connection_Resource.Id


## Approve the Private Endpoint Connection for the SQL Account
$sqlPrivate_Endpoint_Connection_Resource = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $sqlResourceForPrivateLink | Where-Object {($_.PrivateEndpoint.Id -like "*ImportExportPrivateLink_SQL*" -and $_.PrivateLinkServiceConnectionState.status -eq "Pending")}
Start-Sleep -Seconds 30
Approve-AzPrivateEndpointConnection -ResourceId $sqlPrivate_Endpoint_Connection_Resource.Id

#Shows Status
Get-AzSqlDatabaseImportExportStatus  -OperationStatusLink $exportRequest.OperationStatusLink | Where-Object {($_.Status -eq "InProgress")}
