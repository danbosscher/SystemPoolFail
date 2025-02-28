#!/bin/bash
set -e

cd "$(dirname "$0")/terraform"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init
# Deploy infrastructure with automatic destroy on failure
clear
echo "This will deploy to the following Azure Subscription:"
az account show --query name -o tsv
if ! terraform apply; then
    echo "Error detected during deployment. Exiting..."
    exit 1
fi

echo "Deployment completed successfully! Setting up kubectl & deploying v6 SKU disk fix:"

RESOURCE_GROUP=$(terraform output -raw resource_group_name)
STANDARD_AKS_NAME=$(terraform output -raw standard_aks_name 2>/dev/null || echo "")
AUTOMATIC_AKS_NAME=$(terraform output -raw automatic_aks_name 2>/dev/null || echo "")

# Disk fix for Standard Cluster (if deployed)
if [ -n "$STANDARD_AKS_NAME" ]; then
  echo "🚀 Deploying disk fix to Standard AKS Cluster: $STANDARD_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $STANDARD_AKS_NAME --overwrite-existing
  kubectl apply -f https://raw.githubusercontent.com/andyzhangx/demo/refs/heads/master/aks/download-v6-disk-rules.yaml
  echo "✅ Standard cluster complete!"
fi

# Disk fix for Automatic Cluster (if deployed)
if [ -n "$AUTOMATIC_AKS_NAME" ]; then
  echo "🚀 Deploying to Automatic AKS Cluster: $AUTOMATIC_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $AUTOMATIC_AKS_NAME --overwrite-existing
  kubectl apply -f https://raw.githubusercontent.com/andyzhangx/demo/refs/heads/master/aks/download-v6-disk-rules.yaml
  echo "✅ Automatic cluster complete!"
fi

echo "Done! Connect to your clusters using:"
echo "Standard Cluster:"
echo "kubectl config use-context $STANDARD_AKS_NAME"
echo "Automatic Cluster:"
echo "kubectl config use-context $AUTOMATIC_AKS_NAME"