output "resource_group_name" {
  description = "Resource group containing the AKS environment."
  value       = data.azurerm_resource_group.project.name
}

output "vnet_id" {
  description = "ID of the AKS virtual network."
  value       = azurerm_virtual_network.project.id
}

output "aks_subnet_id" {
  description = "ID of the AKS node subnet."
  value       = azurerm_subnet.aks_nodes.id
}

output "outbound_ip_address" {
  description = "Stable public IP used for AKS outbound traffic."
  value       = azurerm_public_ip.egress.ip_address
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.platform.name
}

output "application_gateway_controller_client_id" {
  description = "Client ID used by the Application Gateway for Containers ALB Controller."
  value       = azurerm_user_assigned_identity.application_gateway_controller.client_id
}

output "kubernetes_version" {
  description = "Kubernetes version used by AKS."
  value       = azurerm_kubernetes_cluster.platform.kubernetes_version
}

output "configure_kubectl" {
  description = "Command that configures kubectl with AKS administrator credentials."
  value       = "az aks get-credentials --admin --resource-group ${data.azurerm_resource_group.project.name} --name ${azurerm_kubernetes_cluster.platform.name}"
}
