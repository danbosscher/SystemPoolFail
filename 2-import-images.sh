#!/bin/bash
set -e

# This script imports container images from various registries into your own Azure Container Registry

# Get outputs from terraform
cd "$(dirname "$0")/terraform"
ACR_NAME=$(terraform output -raw acr_login_server)

echo "🔐 Logging into Azure Container Registry ($ACR_NAME)..."
az acr login --name $(echo $ACR_NAME | cut -d'.' -f1)

# Define all images to import with their source and target paths
declare -A IMAGES=(
  ["ghcr.io/azure-samples/aks-store-demo/ai-service:latest"]="${ACR_NAME}/aks-store-demo/ai-service:latest"
  ["ghcr.io/azure-samples/aks-store-demo/order-service:latest"]="${ACR_NAME}/aks-store-demo/order-service:latest"
  ["ghcr.io/azure-samples/aks-store-demo/makeline-service:latest"]="${ACR_NAME}/aks-store-demo/makeline-service:latest"
  ["ghcr.io/azure-samples/aks-store-demo/product-service:latest"]="${ACR_NAME}/aks-store-demo/product-service:latest"
  ["ghcr.io/azure-samples/aks-store-demo/store-admin:latest"]="${ACR_NAME}/aks-store-demo/store-admin:latest"
  ["ghcr.io/azure-samples/aks-store-demo/store-front:latest"]="${ACR_NAME}/aks-store-demo/store-front:latest"
  ["ghcr.io/azure-samples/aks-store-demo/virtual-customer:latest"]="${ACR_NAME}/aks-store-demo/virtual-customer:latest"
  ["ghcr.io/azure-samples/aks-store-demo/virtual-worker:latest"]="${ACR_NAME}/aks-store-demo/virtual-worker:latest"
  ["mcr.microsoft.com/mirror/docker/library/rabbitmq:3.10-management-alpine"]="${ACR_NAME}/library/rabbitmq:3.10-management-alpine"
  ["mcr.microsoft.com/mirror/docker/library/mongo:4.2"]="${ACR_NAME}/library/mongo:4.2"
  ["polinux/stress"]="${ACR_NAME}/stress:latest"
  ["ghcr.io/headlamp-k8s/headlamp:v0.29.0"]="${ACR_NAME}/headlamp:v0.29.0"
  ["busybox:latest"]="${ACR_NAME}/busybox:latest"
)

echo "🔄 Importing images to $ACR_NAME..."

# Loop through all images and import them
for SOURCE_IMAGE in "${!IMAGES[@]}"; do
  TARGET_IMAGE=${IMAGES[$SOURCE_IMAGE]}

  echo "📦 Importing $SOURCE_IMAGE to $TARGET_IMAGE"

  # Pull the image from source
  docker pull $SOURCE_IMAGE

  # Tag it for ACR
  docker tag $SOURCE_IMAGE $TARGET_IMAGE

  # Push to ACR
  docker push $TARGET_IMAGE

  echo "✅ Successfully imported $(basename $SOURCE_IMAGE | cut -d':' -f1)"
done

echo "✅ All images have been imported to $ACR_NAME"