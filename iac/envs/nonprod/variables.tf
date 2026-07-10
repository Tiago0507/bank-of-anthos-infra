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
  description = "Name of the EKS (Elastic Kubernetes Service) cluster shared by the dev and staging namespaces. Used now to tag the VPC's (Virtual Private Cloud's) subnets, and later to actually create the EKS cluster with this exact name."
  type        = string
  default     = "bank-of-anthos-nonprod"
}

variable "github_org" {
  description = "GitHub organization or username that owns the application repository, used to scope the GitHub Actions OIDC (OpenID Connect) trust policy."
  type        = string
  default     = "Tiago0507"
}

variable "github_repo" {
  description = "Name of the GitHub repository allowed to assume the GitHub Actions IAM role."
  type        = string
  default     = "bank-of-anthos"
}

variable "gitops_reader_app_id" {
  description = "App ID of the bank-of-anthos-gitops-reader GitHub App, used by ArgoCD to read bank-of-anthos-gitops."
  type        = string
}

variable "gitops_reader_installation_id" {
  description = "Installation ID of the bank-of-anthos-gitops-reader GitHub App on bank-of-anthos-gitops."
  type        = string
}

variable "gitops_reader_private_key" {
  description = "Private key (PEM) of the bank-of-anthos-gitops-reader GitHub App. No default: must be supplied via a gitignored *.auto.tfvars file or a TF_VAR_ environment variable, never committed."
  type        = string
  sensitive   = true
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
