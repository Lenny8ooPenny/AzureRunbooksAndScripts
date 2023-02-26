#!/usr/bin/env python3
import azure
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

#keyvault_name = f'https://keyvaultname.vault.azure.net/'
#KeyVaultName = " "

credential = DefaultAzureCredential()
client = SecretClient(vault_url=keyvault_name, credential=credential)

print(" done.")
print(f"Retrieving your secret from {KeyVaultName}.")

retrieved_secret = client.get_secret("SendGridAPIKey")
print(f"Your secret is '{retrieved_secret.value}'.")
