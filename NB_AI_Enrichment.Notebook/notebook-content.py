# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "environment": {
# META       "environmentId": "8035023d-8e4a-9d83-44e7-5c09b1bb316c",
# META       "workspaceId": "00000000-0000-0000-0000-000000000000"
# META     }
# META   }
# META }

# CELL ********************

import notebookutils

VAULT_URL = "https://kv-zomato-ai-thuctd6.vault.azure.net/"
SECRET_NAME = "GEMINI-API-KEY"

GEMINI_API_KEY = notebookutils.credentials.getSecret(
    VAULT_URL,
    SECRET_NAME
)

if not GEMINI_API_KEY:
    raise ValueError("Gemini API Key was not retrieved")
print("Gemini secret retrieced successfully")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
