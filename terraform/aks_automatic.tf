resource "azapi_resource" "aks_automatic" {
  count               = var.deploy_automatic ? 1 : 0
  name                = var.aks_automatic_name
  location            = var.location
  parent_id           = azurerm_resource_group.aks_rg.id
  type                = "Microsoft.ContainerService/managedClusters@2024-03-02-preview"
  schema_validation_enabled = false

  body = jsonencode({
    properties = {
      dnsPrefix = "${var.aks_automatic_name}-dns"
      kubernetesVersion = var.kubernetes_version
      agentPoolProfiles = [
        {
          name = "system"
          count = var.system_node_count
          vmSize = var.sku
          mode = "System"
          orchestratorVersion = var.kubernetes_version
          availabilityZones = [for z in var.zones : tostring(z)]
        },
        {
          name = "user"
          count = var.user_node_count
          vmSize = var.sku
          mode = "User"
          availabilityZones = [for z in var.zones : tostring(z)]
        }
      ],
      # Add Azure Policy configuration
      addonProfiles = {
        azurepolicy = {
          enabled = true
        },
        # Add Azure Monitor configuration
        omsagent = {
          enabled = true,
          config = {
            logAnalyticsWorkspaceResourceID = azurerm_log_analytics_workspace.aks.id
          }
        }
      },
      # Add AAD integration
      aadProfile = {
        managed = true,
        adminGroupObjectIDs = [var.aad_admin_group_object_id],
        tenantID = var.aad_tenant_id
      }
    }
    identity = {
      type = "SystemAssigned"
    }
    sku = {
      name = "Automatic"
      tier = "Standard"
    }
    tags = var.tags
  })
}
