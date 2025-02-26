output "standard_aks_host" {
  description = "The Kubernetes host for the standard AKS cluster"
  value       = var.deploy_standard ? azurerm_kubernetes_cluster.aks_standard[0].kube_config.0.host : null
  sensitive   = true
}

output "automatic_aks_id" {
  description = "The resource ID of the automatic AKS cluster"
  value       = var.deploy_automatic ? azapi_resource.aks_automatic[0].id : null
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.aks_rg.name
}

output "standard_aks_name" {
  description = "The name of the standard AKS cluster"
  value       = var.deploy_standard ? var.aks_standard_name : null
}

output "automatic_aks_name" {
  description = "The name of the automatic AKS cluster"
  value       = var.deploy_automatic ? var.aks_automatic_name : null
}
