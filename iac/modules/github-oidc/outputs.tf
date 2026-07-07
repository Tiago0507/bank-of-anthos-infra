output "role_arn" {
  description = "ARN (Amazon Resource Name) of the IAM role GitHub Actions assumes. Set this as the AWS_ROLE_ARN repository variable in GitHub (Settings > Secrets and variables > Actions > Variables)."
  value       = aws_iam_role.github_actions.arn
}
