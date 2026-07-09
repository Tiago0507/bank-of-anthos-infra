variable "aws_region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used as a prefix for resource names and tags."
  type        = string
  default     = "bank-of-anthos"
}
