#Authentication.
Disable-AzContextAutosave -Scope Process
Connect-AzAccount -Identity
Set-AzContext -SubscriptionId "##########################"

#Defining variables.
$vaultName = ""
$kvRG = ""
$kv = Get-AzKeyVault -ResourceGroupName $kvRG -VaultName $vaultName
$secrets = Get-AzKeyVaultSecret -VaultName $kv.VaultName
$keys = Get-AzKeyVaultKey -VaultName $kv.VaultName

$nonExpiringSecrets = $secrets | Where-Object {$_.Expires -eq $null}
$expiringSecrets = $secrets | Where-Object {$_.Expires -ne $null}

$nonExpiringKeys = $keys | Where-Object {$_.Expires -eq $null}
$expiringKeys = $keys | Where-Object {$_.Expires -ne $null}

$daysToCheck = 15
$expireDate = (Get-Date).AddDays($daysToCheck)

#Check expiring secrets in keyvault
foreach ($expiringSecret in $expiringSecrets)
{
    if ($expiringSecret.Expires -lt $expireDate)
    {
        Write-Host ($expiringSecret).name "is in the expiry window of $daysToCheck days"
    }
}
foreach ($nonExpiringSecret in $nonExpiringSecrets)
{
    Write-host ($nonExpiringSecret).name " is set to NEVER expire"
}

#Check expiring keys in keyvault
foreach ($K in $keys)
{
    if ($Key.Expires -lt $expireDate)
    {
        Write-Host ($K).name "is in the expiry window of $daysToCheck days"
    }
}
foreach ($nonKeys in $keys)
{
    Write-host ($nonKeys).name " is set to NEVER expire"
}
