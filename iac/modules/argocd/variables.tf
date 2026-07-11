variable "github_org" {
  description = "GitHub organization or username that owns the bank-of-anthos-gitops repository."
  type        = string
}

variable "environments" {
  description = "Environment names this ArgoCD installation manages. One Application is created per entry, watching overlays/<name> in bank-of-anthos-gitops and deploying into the <name> namespace — both the overlay path and the destination namespace are derived directly from this name."
  type        = set(string)
}

variable "chart_version" {
  description = "Version of the argo-cd Helm chart to install, pinned deliberately instead of tracking latest."
  type        = string
  default     = "10.1.2"
}

# Credentials for the bank-of-anthos-gitops-reader GitHub App (read-only,
# installed only on bank-of-anthos-gitops), used so ArgoCD can clone that
# private repository without a static, long-lived token or SSH key.
variable "gitops_reader_app_id" {
  description = "App ID of the bank-of-anthos-gitops-reader GitHub App."
  type        = string
}

variable "gitops_reader_installation_id" {
  description = "Installation ID of the bank-of-anthos-gitops-reader GitHub App on bank-of-anthos-gitops."
  type        = string
}

variable "gitops_reader_private_key" {
  description = "Private key (PEM) of the bank-of-anthos-gitops-reader GitHub App. Never has a default; must come from a .auto.tfvars file or TF_VAR_ environment variable, never committed."
  type        = string
  sensitive   = true
}
