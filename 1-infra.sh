#!/bin/bash
set -e

cd "$(dirname "$0")/terraform"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan the deployment
echo "Planning deployment..."
terraform plan -out=tfplan

echo "Starting deployment with automatic rollback on failure..."
# Use -parallelism=10 for more concurrent operations
if ! terraform apply -parallelism=10 -auto-approve tfplan; then
    echo "Error detected during deployment. Rolling back..."
    terraform destroy -auto-approve
    echo "Rollback complete. Exiting with error."
    exit 1
fi

echo "Deployment completed successfully!"
echo "Setting up kubectl context..."
az aks get-credentials -g $(terraform output -raw resource_group_name) -n $(terraform output -raw standard_aks_name) --admin
az aks get-credentials -g $(terraform output -raw resource_group_name) -n $(terraform output -raw automatic_aks_name) --admin
kubectl config get-contexts