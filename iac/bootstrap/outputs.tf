# Other modules (ecr, vpc, eks, irsa) hardcode these same values in their own
# backend "s3" block. Terraform backend configuration cannot reference
# outputs directly, so these values must be copied once into each module's
# backend block; they are not wired automatically.
output "state_bucket_name" {
  description = "S3 bucket holding Terraform state for all other modules."
  value       = aws_s3_bucket.tfstate.id
}

output "state_bucket_arn" {
  value = aws_s3_bucket.tfstate.arn
}

output "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.tf_lock.name
}

output "aws_region" {
  value = var.aws_region
}
