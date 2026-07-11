output "vpc_id" {
  description = "ID of the VPC (Virtual Private Cloud)."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ (Availability Zone)."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ (Availability Zone)."
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS (Elastic Kubernetes Service) cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "URL of the Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "ARN (Amazon Resource Name) of the cluster's OIDC (OpenID Connect) provider, needed by the IRSA (IAM Roles for Service Accounts) module."
  value       = module.eks.oidc_provider_arn
}

output "irsa_role_arn" {
  description = "ARN (Amazon Resource Name) of the IRSA (IAM Roles for Service Accounts) role. Set this as the eks.amazonaws.com/role-arn annotation on the bank-of-anthos ServiceAccount."
  value       = module.irsa.role_arn
}
