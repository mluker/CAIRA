#!/bin/bash
# ---------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. Licensed under the MIT license.
# ---------------------------------------------------------------------

# configure-local-settings.sh - Configure local settings for AI Foundry integration

set -e

echo "Configuring local settings for Azure Functions development..."

# Navigate to terraform directory
cd ../terraform

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
  echo "Error: Terraform state not found in $(pwd)"
  echo "Please ensure the Azure Functions layer has been deployed first."
  echo ""
  echo "To deploy:"
  echo "  terraform init"
  echo "  terraform apply"
  exit 1
fi

echo "Extracting configuration from terraform outputs..."

# Get all values from terraform outputs
FUNCTION_APP_NAME=$(terraform output -raw function_app_name)
FUNCTION_APP_URL=$(terraform output -raw function_app_url)
RESOURCE_GROUP=$(terraform output -raw foundry_resource_group_name)
AI_FOUNDRY_ENDPOINT=$(terraform output -raw ai_foundry_endpoint)
AI_FOUNDRY_PROJECT_NAME=$(terraform output -raw ai_foundry_project_name)
AI_FOUNDRY_PROJECT_ID=$(terraform output -raw ai_foundry_project_id)
AZURE_SUBSCRIPTION_ID=$(terraform output -raw subscription_id)

# Navigate to function-app directory
cd ../function-app

# Create local.settings.json
cat >local.settings.json <<EOF
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "FUNCTIONS_EXTENSION_VERSION": "~4",
    "AI_FOUNDRY_ENDPOINT": "$AI_FOUNDRY_ENDPOINT",
    "AI_FOUNDRY_PROJECT_NAME": "$AI_FOUNDRY_PROJECT_NAME",
    "AI_FOUNDRY_PROJECT_ID": "$AI_FOUNDRY_PROJECT_ID",
    "RESOURCE_GROUP": "$RESOURCE_GROUP",
    "AZURE_SUBSCRIPTION_ID": "$AZURE_SUBSCRIPTION_ID",
    "MODEL_DEPLOYMENT_NAME": "gpt-4",
    "FUNCTION_APP_NAME": "$FUNCTION_APP_NAME",
    "FUNCTION_APP_URL": "$FUNCTION_APP_URL"
  },
  "Host": {
    "LocalHttpPort": 7071,
    "CORS": "*",
    "CORSCredentials": false
  }
}
EOF

echo ""
echo "✅ Local settings configured successfully!"
echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "Resource Group: $RESOURCE_GROUP"
echo "AI Foundry Endpoint: $AI_FOUNDRY_ENDPOINT"
echo "AI Foundry Project: $AI_FOUNDRY_PROJECT_NAME"
echo "AI Foundry Project ID: $AI_FOUNDRY_PROJECT_ID"
echo "Subscription ID: $AZURE_SUBSCRIPTION_ID"
echo "Function App Name: $FUNCTION_APP_NAME"
echo "Function App URL: $FUNCTION_APP_URL"
echo ""
echo "Files created:"
echo "- local.settings.json (for Azure Functions Core Tools)"
echo ""
echo "You can now run 'func start' to test locally."
