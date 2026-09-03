output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS region."
  value       = var.aws_region
}

output "ghcr_secret_name" {
  description = "Secrets Manager secret name containing GHCR pull credentials."
  value       = var.ghcr_secret_name
}

output "application_domain_name" {
  description = "Public DNS name used for the EKS application."
  value       = var.application_domain_name
}

output "hosted_zone_name" {
  description = "Route 53 hosted zone used for application records."
  value       = var.hosted_zone_name
}

output "application_certificate_arn" {
  description = "ARN of the validated ACM certificate for the application."
  value       = aws_acm_certificate_validation.application.certificate_arn
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used for load balancers and NAT Gateway placement."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS managed node group."
  value       = module.vpc.private_subnets
}

output "configure_kubectl" {
  description = "Command to configure kubectl for this cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
