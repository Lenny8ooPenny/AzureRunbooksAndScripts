#https://learnwithlenny.azurewebsites.net/2022/11/28/blog-6-how-to-append-multiple-log-type-files-to-one-main-file-with-powershell-and-store-in-azure-blob-storage/

#Auth piece.
Disable-AzContextAutosave -Scope Process
Connect-AzAccount -Identity -Subscription "###################"

New-Item -ItemType File -Name "MainParentLog.csv" -Value "This is line 1"
New-Item -ItemType File -Name "Newlogs.csv" -Value  "This is line 3"

$ResourceGroupName = 'Test-Storage'
$StorageAccountName = 'teststorageacclk'
$ContainerName = 'test'
$context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).context
$sasToken = New-AzStorageAccountSASToken -Context $context -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission racwdlup
$StorageContext = New-AzStorageContext $StorageAccountName -SasToken $sasToken

#---------------------------------------------------------------------------Execution-----------------------------------------------------------------------------------
#Checks if parent file is there, if not it will create it. When the script runs again, it checks for that file. If it's there, it will upload the new file, pull the data from both
#files and create a new one, over writing the parent file with all the data - previous and new. It then removes the last file added as it is now unneeded.

try 
{ 	$X = Invoke-WebRequest -Method Head "https://teststorageacclk.blob.core.windows.net/test/MainParentLog.csv" -UseBasicParsing
	Write-Output "File is present in 'test' container. Look for file called 'MainParentLog.csv'"	

	#Grab file and it's data.
	$blob = Get-AzStorageBlob -Container $ContainerName -Blob "MainParentLog.csv" -Context $StorageContext 
	$blobdata = $blob.ICloudBlob.DownloadText()
	Write-Output "Data from the parent file below:"
	Write-Output $blobdata

	#Upload newly generated log file to container to extract data in the next step.
	$storageContainer = Get-AzStorageContainer -Name $ContainerName -Context $StorageContext
	$storageContainer | Set-AzStorageBlobContent -BlobType Append –File '.\Newlogs.csv' –Blob 'Newlogs.csv'
	Write-Output "Uploading new file called 'Newlogs.csv' to container."
	Start-sleep -S 5

	#Extract data from that new file.
	$NewBlob = Get-AzStorageBlob -Container $ContainerName -Blob "Newlogs.csv" -Context $StorageContext 
	$NewBlobData = $NewBlob.ICloudBlob.DownloadText()
	Write-Output "Data from the new file called 'Newlogs.csv' below:"
	Write-Output $NewBlobData

	#Create new file with previous parent data + new file data.
	$newrow = @"
	Logs,
	$blobdata,
	$NewBlobData
"@

	#Create new log file with data from 1st file + new entries.
	Write-Output "Creating new parent file locally."
	New-Item -ItemType File -Name "UpdatedLogFile.csv" -Value $newrow

	#Upload the new file.
	Write-Output "Uploading newly generated file from local directory to storage container overwriting original parent file."
	$storageContainer = Get-AzStorageContainer -Name $ContainerName -Context $StorageContext
	$storageContainer | Set-AzStorageBlobContent -BlobType Append –File '.\UpdatedLogFile.csv' –Blob 'MainParentLog.csv' -Force
	Start-Sleep -S 5

	$UpdatedBlob = Get-AzStorageBlob -Container $ContainerName -Blob "MainParentLog.csv" -Context $StorageContext 
	$UpdatedBlobData = $UpdatedBlob.ICloudBlob.DownloadText()
	Write-Output "Data from new file below:"
	Write-Output $UpdatedBlobData

	#Remove old blobs to only keep the new one. 
	Remove-AzStorageBlob -Container $ContainerName -Blob "Newlogs.csv" -Context $StorageContext
	Write-Output "Success. Now removing unnecessary blobs."
}	
catch
{
if( $_.exception -like "*404*" )
	{
	
Write-Output "Blob called 'MainParentLog.csv' doesn't exist, but will be created now!!!"

$storageContainer = Get-AzStorageContainer -Name $ContainerName -Context $StorageContext
$storageContainer | Set-AzStorageBlobContent -BlobType Append –File '.\MainParentLog.csv' –Blob 'MainParentLog.csv'
	}
}
