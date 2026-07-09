output "role_arn" {
  description = "ARN (Amazon Resource Name) of the IAM role. Set this as the eks.amazonaws.com/role-arn annotation on the bank-of-anthos ServiceAccount, replacing the old GCP Workload Identity annotation."
  value       = aws_iam_role.this.arn
}
