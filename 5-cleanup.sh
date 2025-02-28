#!/bin/bash
set -e

cd "$(dirname "$0")/terraform"

# Destroy the environment using Terraform
echo "Destroying environment using Terraform..."
if terraform destroy -auto-approve; then
    echo "Environment destroyed successfully!"
else
    echo "Failed to destroy the environment."
    exit 1
    echo "Please check your Terraform configuration and try again."
fi