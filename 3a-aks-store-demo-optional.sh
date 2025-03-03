#!/bin/bash
set -e

# Source common functions
source "$(dirname "$0")/common-functions.sh"

# Get ACR login server from Terraform
cd "$(dirname "$0")/terraform"
ACR_NAME=$(terraform output -raw acr_login_server)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
STANDARD_AKS_NAME=$(terraform output -raw standard_aks_name 2>/dev/null || echo "")
AUTOMATIC_AKS_NAME=$(terraform output -raw automatic_aks_name 2>/dev/null || echo "")
cd ..

echo "📦 Using Azure Container Registry: $ACR_NAME"

# Create values file with ACR configuration
update_acr_values "$ACR_NAME"

echo "🔑 Getting credentials for AKS clusters..."

# Standard Cluster (if deployed)
if [ -n "$STANDARD_AKS_NAME" ]; then
  echo "🚀 Deploying to Standard AKS Cluster: $STANDARD_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $STANDARD_AKS_NAME --overwrite-existing
  kubectl create namespace aks-store --dry-run=client -o yaml | kubectl apply -f -

  # Create ACR pull secret
  create_acr_pull_secret "aks-store" "$ACR_NAME"

  echo "📦 Installing Helm chart with ACR images..."
  helm upgrade --install aks-store-demo charts/aks-store-demo -n aks-store -f acr-values.yaml

  echo "✅ Deployment to Standard cluster complete!"
fi

# Automatic Cluster (if deployed)
if [ -n "$AUTOMATIC_AKS_NAME" ]; then
  echo "🚀 Deploying to Automatic AKS Cluster: $AUTOMATIC_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $AUTOMATIC_AKS_NAME --overwrite-existing
  kubectl create namespace aks-store --dry-run=client -o yaml | kubectl apply -f -

  # Create ACR pull secret
  create_acr_pull_secret "aks-store" "$ACR_NAME"

  echo "📦 Installing Helm chart with ACR images..."
  helm upgrade --install aks-store-demo charts/aks-store-demo -n aks-store -f acr-values.yaml

  echo "✅ Deployment to Automatic cluster complete!"
fi

echo ""
echo "To access the store front service, run:"
echo "kubectl get service store-front -n aks-store"
echo ""
echo "To access the store admin service, run:"
echo "kubectl get service store-admin -n aks-store"