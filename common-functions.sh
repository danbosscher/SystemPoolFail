#!/bin/bash

# Creates a Docker registry pull secret for ACR in the specified namespace
create_acr_pull_secret() {
  local namespace=$1
  local acr_name=$2

  echo "Creating ACR pull secret in namespace '$namespace'..."

  # Extract ACR server name for credential lookup
  local acr_server_name=$(echo $acr_name | cut -d '.' -f 1)

  # Get ACR credentials
  local ACR_USERNAME=$(az acr credential show -n $acr_server_name --query username -o tsv)
  local ACR_PASSWORD=$(az acr credential show -n $acr_server_name --query "passwords[0].value" -o tsv)

  # Create the secret
  kubectl create secret docker-registry acr-auth \
    --namespace $namespace \
    --docker-server=$acr_name \
    --docker-username=$ACR_USERNAME \
    --docker-password=$ACR_PASSWORD \
    --docker-email=user@example.com \
    --dry-run=client -o yaml | kubectl apply -f -

  echo "✅ ACR pull secret created in namespace '$namespace'"
}

# Updates the acr-values.yaml file with the current ACR name
update_acr_values() {
  local acr_name=$1
  local output_file="${2:-acr-values.yaml}"

  echo "Updating ACR values in $output_file..."

  cat > "$output_file" << EOF
# Configuration for ACR integration - automatically generated, do not edit manually
imageRegistry: "$acr_name"
imagePullSecrets:
  - name: acr-auth
EOF

  echo "✅ ACR values updated in $output_file"
}

# Updates the headlamp-values.yaml file with the current ACR name
update_headlamp_values() {
  local acr_name=$1
  local output_file="${2:-headlamp-values.yaml}"

  echo "Updating Headlamp values in $output_file..."

  cat > "$output_file" << EOF
# Custom values for Headlamp deployed from ACR
image:
  registry: "$acr_name"
  repository: "headlamp"
  tag: "v0.29.0"
  pullPolicy: IfNotPresent

# Configure image pull secrets
imagePullSecrets:
  - name: acr-auth

# Add resource limits to satisfy container policy
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
EOF

  echo "✅ Headlamp values updated in $output_file"
}