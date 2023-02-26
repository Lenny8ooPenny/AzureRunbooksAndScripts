Param(
  [Parameter(Mandatory=$True)]
  [String] $destEmailAddress,
  [Parameter(Mandatory=$False)]
  [String] $fromEmailAddress,
  [Parameter(Mandatory=$True)]
  [String] $subject,
  [Parameter(Mandatory=$True)]
  [String] $content,
  [Parameter(Mandatory=$True)]
  [String] $ResourceGroupName
)

$fromEmailAddress = ''

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext 

$VaultName = ""

$SENDGRID_API_KEY = Get-AzKeyVaultSecret `
    -VaultName $VaultName `
    -Name "" `
    -AsPlainText -DefaultProfile $AzureContext

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
subject = $subject
content = @(
    @{
        type = "text/plain"
        value = $content
    }
)
}

$bodyJson = $body | ConvertTo-Json -Depth 4

$response = Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson
