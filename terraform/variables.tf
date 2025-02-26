variable "location" {
  description = "Azure region to deploy resources"
  default     = "northeurope"
  type        = string
}

variable "sku" {
  description = "VM size for AKS node pools"
  default     = "Standard_D8ads_v6"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for all resources"
  default     = "AKS-Demo-RG"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS clusters"
  default     = "1.30.9"
  type        = string
}

variable "aks_standard_name" {
  description = "Name of the standard AKS cluster"
  default     = "aks-standard"
  type        = string
}

variable "aks_automatic_name" {
  description = "Name for the AKS cluster with automatic node provisioning"
  type        = string
  default     = "aks-automatic"
}

variable "deploy_standard" {
  description = "Whether to deploy the standard AKS cluster"
  default     = true
  type        = bool
}

variable "deploy_automatic" {
  description = "Boolean to deploy the AKS cluster with automatic node provisioning"
  type        = bool
  default     = false
}

variable "system_node_count" {
  description = "Initial node count for system pools"
  default     = 3
  type        = number
}

variable "user_node_count" {
  description = "Initial node count for user pools"
  default     = 3
  type        = number
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Demo"
    Project     = "AKS-Comparison"
  }
}

variable "zones" {
  description = "Availability zones for node pools"
  type        = list(number)
  default     = [1, 2, 3]
}

variable "enable_auto_scaling" {
  description = "Whether to enable auto-scaling for node pools"
  type        = bool
  default     = true
}

variable "max_node_count" {
  description = "Maximum number of nodes in a node pool when auto-scaling"
  type        = number
  default     = 6
}

variable "aad_tenant_id" {
  description = "Azure Active Directory tenant ID for AKS cluster integration"
  type        = string
  # No default - this should be provided in terraform.tfvars or as a command-line variable
}

variable "aad_admin_group_object_id" {
  description = "Object ID of the AAD group that will have admin access to the AKS cluster"
  type        = string
  # No default - this should be provided in terraform.tfvars or as a command-line variable
}
