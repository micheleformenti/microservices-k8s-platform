variable "name" {
  description = "Name used for the EKS cluster and supporting resources."
  type        = string
  default     = "microservices-platform-eks"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-central-1"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version. Use a version in standard support to avoid extended support fees."
  type        = string
  default     = "1.36"
}

variable "vpc_cidr" {
  description = "CIDR block for the experiment VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for all private subnets to reduce demo cost. Set to false for one NAT Gateway per private subnet."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Use SPOT for lower cost or ON_DEMAND for fewer interruptions."
  type        = string
  default     = "SPOT"

  validation {
    condition     = contains(["SPOT", "ON_DEMAND"], var.node_capacity_type)
    error_message = "node_capacity_type must be SPOT or ON_DEMAND."
  }
}

variable "node_min_size" {
  description = "Minimum worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum worker nodes."
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired worker nodes."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Additional tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}
