resource "azurerm_kubernetes_cluster" "aks_standard" {
  count               = var.deploy_standard ? 1 : 0
  name                = var.aks_standard_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = "${var.aks_standard_name}-dns"
  tags                = var.tags

  # Enable Azure Policy
  azure_policy_enabled = true

  # Enable Azure Monitor
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  default_node_pool {
    name                 = "system"
    vm_size              = var.sku
    node_count           = var.system_node_count
    orchestrator_version = var.kubernetes_version
    zones                = var.zones
    enable_auto_scaling  = var.enable_auto_scaling
    min_count            = var.system_node_count
    max_count            = var.max_node_count
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to node count as it will be managed by the autoscaler
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  count                = var.deploy_standard ? 1 : 0
  name                 = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_standard[0].id
  vm_size              = var.sku
  node_count           = var.user_node_count
  zones                = var.zones
  enable_auto_scaling  = var.enable_auto_scaling
  min_count            = var.user_node_count
  max_count            = var.max_node_count
  tags                 = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to node count as it will be managed by the autoscaler
      node_count
    ]
  }
}