# Set these variables to the proper values for your environment
$fromEmailAddress = "from email address"
$destEmailAddress = "to email address"
$subscriptionId = ""
$region = ""
$vpnConnectionName = ""
$vpnConnectionResourceGroup = ""
$storageAccountName = ""
$storageAccountResourceGroup = ""
$storageAccountContainer = ""

try
{
    "Logging in to Azure..."
    Disable-AzContextAutosave -Scope Process
    Connect-AzAccount -Identity
    $AzureContext = Set-AzContext -SubscriptionId $subscriptionId

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$networkWatcher = Get-AzNetworkWatcher -Name "" -ResourceGroupName ""
$connection = Get-AzVirtualNetworkGatewayConnection -Name $vpnConnectionName -ResourceGroupName $vpnConnectionResourceGroup
$sa = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $storageAccountResourceGroup 
$storagePath = "$($sa.PrimaryEndpoints.Blob)$($storageAccountContainer)"
$result = Start-AzNetworkWatcherResourceTroubleshooting -NetworkWatcher $networkWatcher -TargetResourceId $connection.Id -StorageId $sa.Id -StoragePath $storagePath

#Sending email with SendGrid

if($result.code -ne "Healthy")
    {
      $SubjectLineFailure = "$($connection.name) Status"
      $EmailBodyContentFailure = "Connection for $($connection.name) is: $($result.code) `n$($result.results[0].summary) `nView the logs at $($storagePath) to learn more."

      #Variables for using SendGrid service.
      $VaultName = ""
      $SENDGRID_API_KEY = Get-AzKeyVaultSecret -VaultName $VaultName -Name "Name of key object" -AsPlainText -DefaultProfile $AzureContext
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $headers.Add("Authorization", "Bearer " + $SENDGRID_API_KEY)
      $headers.Add("Content-Type", "application/json")

$body = @{
  personalizations = @(
      @{
          to = @(
                  @{
                      email = $destEmailAddress
                  }
          )
      }
  )
  from = @{
      email = $fromEmailAddress
  }
  subject = $SubjectLineFailure
  content = @(
      @{
          type = "text/plain"
          value = $EmailBodyContentFailure
      }
  )
}

$bodyJson = $body | ConvertTo-Json -Depth 4
Write-Output "Sending out vpn failure email to customer..."
$response = Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson

    }
else
    {
      Write-Output ("Connection Status is: $($result.code)")

      $SubjectLineSuccess = "Connection Status is: $($result.code)"
      $EmailBodyContentSuccess = "Connection is up and running."

      #Variables for using SendGrid service.
      $VaultName = ""
      $SENDGRID_API_KEY = Get-AzKeyVaultSecret -VaultName $VaultName -Name "Name of key object" -AsPlainText -DefaultProfile $AzureContext
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $headers.Add("Authorization", "Bearer " + $SENDGRID_API_KEY)
      $headers.Add("Content-Type", "application/json")

$body = @{
  personalizations = @(
      @{
          to = @(
                  @{
                      email = $destEmailAddress
                  }
          )
      }
  )
  from = @{
      email = $fromEmailAddress
  }
  subject = $SubjectLineSuccess
  content = @(
      @{
          type = "text/plain"
          value = $EmailBodyContentSuccess
      }
  )
}

$bodyJson2 = $body | ConvertTo-Json -Depth 4
Write-Output "Sending out vpn success email to customer..."

$response = Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson2
}
