#!/bin/bash
set -e

# Source common functions
source "$(dirname "$0")/common-functions.sh"

# Get resource group and cluster names from Terraform
cd "$(dirname "$0")/terraform"
ACR_NAME=$(terraform output -raw acr_login_server)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
STANDARD_AKS_NAME=$(terraform output -raw standard_aks_name 2>/dev/null || echo "")
AUTOMATIC_AKS_NAME=$(terraform output -raw automatic_aks_name 2>/dev/null || echo "")
cd ..

echo "📦 Using Azure Container Registry: $ACR_NAME"
echo "🔑 Getting credentials for AKS clusters..."

# Update headlamp-values.yaml with the current ACR name
update_headlamp_values "$ACR_NAME"

# Standard Cluster (if deployed)
if [ -n "$STANDARD_AKS_NAME" ]; then
  echo "🚀 Connecting to Standard AKS Cluster: $STANDARD_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $STANDARD_AKS_NAME --overwrite-existing

  echo "📦 Installing Headlamp on Standard cluster..."
  kubectl create namespace headlamp --dry-run=client -o yaml | kubectl apply -f -

  # Create ACR pull secret for Headlamp
  create_acr_pull_secret "headlamp" "$ACR_NAME"

  # Use our local chart with custom values
  helm upgrade --install headlamp ./charts/headlamp \
    --namespace headlamp \
    -f ./headlamp-values.yaml

  echo "✅ Headlamp installation on Standard cluster complete!"
fi

# Automatic Cluster (if deployed)
if [ -n "$AUTOMATIC_AKS_NAME" ]; then
  echo "🚀 Connecting to Automatic AKS Cluster: $AUTOMATIC_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $AUTOMATIC_AKS_NAME --overwrite-existing

  echo "📦 Installing Headlamp on Automatic cluster..."
  kubectl create namespace headlamp --dry-run=client -o yaml | kubectl apply -f -

  # Create ACR pull secret for Headlamp
  create_acr_pull_secret "headlamp" "$ACR_NAME"

  # Use our local chart with custom values
  helm upgrade --install headlamp ./charts/headlamp \
    --namespace headlamp \
    -f ./headlamp-values.yaml

  echo "✅ Headlamp installation on Automatic cluster complete!"
fi

echo ""
echo "To access Headlamp, you can port-forward the service:"
echo ""
echo "kubectl port-forward service/headlamp -n headlamp 8080:80"
echo ""
echo "Then open your browser at: http://localhost:8080"
echo ""
echo "To get a token for authentication, run:"
echo "kubectl create token headlamp --namespace headlamp"