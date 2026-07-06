variable "aws_region" {
  description = "AWS region for every resource this environment creates."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used as a prefix for resource names and tags."
  type        = string
  default     = "bank-of-anthos"
}

variable "cluster_name" {
  description = "Name of the EKS (Elastic Kubernetes Service) cluster for this environment. Used now to tag the VPC's (Virtual Private Cloud's) subnets, and later to actually create the EKS cluster with this exact name."
  type        = string
  default     = "bank-of-anthos-dev"
}

variable "ecr_repository_names" {
  description = "Names of the ECR repositories to create, one per container image built by this project."
  type        = set(string)
  default = [
    "frontend",
    "userservice",
    "contacts",
    "accounts-db",
    "ledgerwriter",
    "balancereader",
    "transactionhistory",
    "ledger-db",
    "loadgenerator",
  ]
}
