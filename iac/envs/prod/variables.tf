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
  description = "Name of the EKS (Elastic Kubernetes Service) cluster dedicated to prod, separate from the shared nonprod cluster."
  type        = string
  default     = "bank-of-anthos-prod"
}

variable "github_org" {
  description = "GitHub organization or username that owns bank-of-anthos-gitops, used to build the Application's repository URL."
  type        = string
  default     = "Tiago0507"
}

variable "gitops_reader_app_id" {
  description = "App ID of the bank-of-anthos-gitops-reader GitHub App. Shared with the nonprod cluster: a read-only credential can safely serve more than one ArgoCD installation."
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
