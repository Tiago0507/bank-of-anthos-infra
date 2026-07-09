output "cluster_name" {
  description = "Name of the EKS (Elastic Kubernetes Service) cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "URL of the Kubernetes API server, used by kubectl."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data, used by kubectl to verify the API server's identity."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN (Amazon Resource Name) of this cluster's OIDC (OpenID Connect) provider, needed by the IRSA (IAM Roles for Service Accounts) module to build trust policies scoped to this specific cluster."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "Issuer URL of this cluster's OIDC (OpenID Connect) provider, without the https:// prefix stripped, as needed by IRSA (IAM Roles for Service Accounts) trust policies."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
