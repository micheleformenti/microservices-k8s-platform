output "resource_group_name" {
  description = "Resource group containing the AKS environment."
  value       = data.azurerm_resource_group.project.name
}

output "dns_zone_name" {
  description = "Existing Azure DNS zone used for application records."
  value       = data.azurerm_dns_zone.application.name
}

output "dns_zone_resource_group_name" {
  description = "Resource group containing the existing Azure DNS zone."
  value       = data.azurerm_dns_zone.application.resource_group_name
}

output "vnet_id" {
  description = "ID of the AKS virtual network."
  value       = azurerm_virtual_network.project.id
}

output "aks_subnet_id" {
  description = "ID of the AKS node subnet."
  value       = azurerm_subnet.aks_nodes.id
}

output "application_gateway_subnet_id" {
  description = "ID of the delegated Application Gateway for Containers subnet."
  value       = azurerm_subnet.application_gateway.id
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

output "external_dns_client_id" {
  description = "Client ID used by ExternalDNS."
  value       = azurerm_user_assigned_identity.external_dns.client_id
}

output "external_secrets_client_id" {
  description = "Client ID used by External Secrets Operator."
  value       = azurerm_user_assigned_identity.external_secrets.client_id
}

output "key_vault_uri" {
  description = "URI of the persistent Key Vault used for application secrets."
  value       = data.azurerm_key_vault.secrets.vault_uri
}

output "kubernetes_version" {
  description = "Kubernetes version used by AKS."
  value       = azurerm_kubernetes_cluster.platform.kubernetes_version
}

output "configure_kubectl" {
  description = "Command that configures kubectl with AKS administrator credentials."
  value       = "az aks get-credentials --admin --resource-group ${data.azurerm_resource_group.project.name} --name ${azurerm_kubernetes_cluster.platform.name}"
}
