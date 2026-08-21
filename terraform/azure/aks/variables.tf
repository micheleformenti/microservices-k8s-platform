variable "subscription_id" {
  description = "Azure subscription in which to create resources."
  type        = string
}

variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
  default     = "microservices-platform"
}

variable "vnet_address_space" {
  description = "Address space assigned to the AKS virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes assigned to the AKS node subnet."
  type        = list(string)
  default     = ["10.10.0.0/20"]
}

variable "application_gateway_subnet_address_prefixes" {
  description = "Address prefixes assigned to Application Gateway for Containers."
  type        = list(string)
  default     = ["10.10.16.0/24"]
}

variable "kubernetes_version" {
  description = "Kubernetes minor version used by AKS."
  type        = string
  default     = "1.35"
}

variable "node_vm_size" {
  description = "Azure VM size used by the AKS system node pool."
  type        = string
  default     = "Standard_D2s_v6"
}

variable "node_desired_count" {
  description = "Initial number of nodes in the AKS system node pool."
  type        = number
  default     = 2
}

variable "node_min_count" {
  description = "Minimum number of nodes maintained by the AKS Cluster Autoscaler."
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of nodes allowed by the AKS Cluster Autoscaler."
  type        = number
  default     = 4
}

variable "pod_cidr" {
  description = "Private address range assigned to pods by Azure CNI Overlay."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "Private address range assigned to Kubernetes services."
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address assigned to the Kubernetes DNS service."
  type        = string
  default     = "10.0.0.10"
}
