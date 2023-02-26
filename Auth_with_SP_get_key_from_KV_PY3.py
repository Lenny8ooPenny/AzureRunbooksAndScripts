#!/usr/bin/env python3
#Notes: Using Python 3.8.0
#Using modules called: azure_identity and 
#azure_keyvault_secrets

from azure.identity
from azure.keyvault.secrets import SecretClient

AccessToken = get_token(tenant_id:##########################, client_id:###########################, client_secret:############################### )
keyvault_name = f'https://keyvaultURL/'
KeyVaultName = "Key Vault Name"

#credential = DefaultAzureCredential()
client = SecretClient(vault_url=keyvault_name, credential=AccessToken)
