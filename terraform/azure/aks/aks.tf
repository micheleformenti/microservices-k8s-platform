resource "azurerm_kubernetes_cluster" "platform" {
  name                = "aks-${var.project_name}"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name
  node_resource_group = "rg-${var.project_name}-aks-nodes"
  dns_prefix          = "aks-${var.project_name}"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free"

  role_based_access_control_enabled = true

  default_node_pool {
    name                   = "system"
    vm_size                = var.node_vm_size
    vnet_subnet_id         = azurerm_subnet.aks_nodes.id
    node_public_ip_enabled = false
    zones                  = ["1", "2", "3"]

    auto_scaling_enabled = true
    node_count           = var.node_desired_count
    min_count            = var.node_min_count
    max_count            = var.node_max_count
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aks_existing.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    outbound_type       = "userAssignedNATGateway"
    load_balancer_sku   = "standard"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  tags = local.common_tags

  depends_on = [azurerm_subnet_nat_gateway_association.egress]
}
