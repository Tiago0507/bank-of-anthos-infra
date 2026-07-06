# Maps of repository name to its value, so the root configuration that
# invokes this module (iac/envs/dev) can pass the right ECR URL to each
# Kubernetes manifest, or to a future CI pipeline, without hardcoding
# account ID or region anywhere else.
output "repository_urls" {
  description = "Map of repository name to its full ECR URL, used as the image push/pull target."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository name to its ARN, used when granting IAM permissions scoped to a specific repository."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}
