#!/bin/bash
set -e

cd "$(dirname "$0")/terraform"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Deploy infrastructure with automatic rollback on failure
echo "Starting deployment with automatic rollback on failure..."
if ! terraform apply; then
    echo "Error detected during deployment. Rolling back..."
    terraform destroy -auto-approve
    echo "Rollback complete. Exiting with error."
    exit 1
fi

echo "Deployment completed successfully!"
echo "Run these commands to set up kubectl..."
echo "az aks get-credentials -g $(terraform output -raw resource_group_name) -n $(terraform output -raw standard_aks_name) --admin"
echo "az aks get-credentials -g $(terraform output -raw resource_group_name) -n $(terraform output -raw automatic_aks_name) --admin"
echo "Remember to run the disk fix if you're on a v6 SKU"
echo "kubectl apply -f https://raw.githubusercontent.com/andyzhangx/demo/refs/heads/master/aks/download-v6-disk-rules.yaml"