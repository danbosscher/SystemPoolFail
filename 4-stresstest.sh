#!/bin/bash
set -e

# Get resource group and cluster names from Terraform
cd "$(dirname "$0")/terraform"
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
STANDARD_AKS_NAME=$(terraform output -raw standard_aks_name 2>/dev/null || echo "")
AUTOMATIC_AKS_NAME=$(terraform output -raw automatic_aks_name 2>/dev/null || echo "")
cd ..

echo "🔑 Getting credentials for AKS clusters..."

# Standard Cluster (if deployed)
if [ -n "$STANDARD_AKS_NAME" ]; then
  echo "🚀 Connecting to Standard AKS Cluster: $STANDARD_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $STANDARD_AKS_NAME --overwrite-existing

  echo "📦 Installing Headlamp..."
  helm repo add headlamp https://headlamp-k8s.github.io/headlamp/
  helm install my-headlamp headlamp/headlamp --namespace headlamp

  echo "✅ Headlamp installation on Standard cluster complete!"
fi

# Automatic Cluster (if deployed)
if [ -n "$AUTOMATIC_AKS_NAME" ]; then
  echo "🚀 Connecting to Automatic AKS Cluster: $AUTOMATIC_AKS_NAME"
  az aks get-credentials --resource-group $RESOURCE_GROUP --name $AUTOMATIC_AKS_NAME --overwrite-existing

  echo "📦 Installing Headlamp..."
  helm repo add headlamp https://headlamp-k8s.github.io/headlamp/
  helm install my-headlamp-auto headlamp/headlamp --namespace headlamp

  echo "✅ Headlamp installation on Automatic cluster complete!"
fi

echo ""
echo "To access Headlamp, you can port-forward the service:"
echo ""
echo "kubectl port-forward service/my-headlamp -n headlamp 8080:80"
echo ""
echo "Then open your browser at: http://localhost:8080"
echo ""
echo ¨kubectl create token my-headlamp --namespace headlamp"