#Creating a usable SAS token to use to connect to your Blob.

#First connect with your account. 
Connect-AzAccount -Identity

#Set your context first.
$RG = 'Name of resource group'
$accountName = 'Storage Account Name'
$context = (Get-AzStorageAccount -ResourceGroupName $RG -AccountName $accountName).context

#Your variables to create SAS Token
$StartTime = Get-Date
$EndTime = $startTime.AddHours(2)
$Name = 'lennycontainer'
$Permission = 'r'
$Protocol = 'HttpsOrHttp'
$SASToken = New-AzStorageContainerSASToken -Name $Name -Permission $Permission -StartTime $StartTime -ExpiryTime $EndTime -protocol $Protocol -context $context
$SASToken
#Because in $SASToken we used the '-FullUri' parameter, we can then get the full url link with the sas token included. So $SASToken will get you the whole URL.
#Otherwise if you don't want the full URL and only want the SAS Token itself, remove the '-FullUri' parameter in $SASToken
