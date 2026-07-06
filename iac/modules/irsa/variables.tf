variable "cluster_name" {
  description = "Name of the EKS (Elastic Kubernetes Service) cluster, used as a prefix for the role name."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN (Amazon Resource Name) of the cluster's OIDC (OpenID Connect) provider, from the EKS (Elastic Kubernetes Service) module output."
  type        = string
}

variable "oidc_provider_url" {
  description = "Issuer URL of the cluster's OIDC (OpenID Connect) provider, from the EKS (Elastic Kubernetes Service) module output."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the ServiceAccount this role is scoped to."
  type        = string
  default     = "default"
}

variable "service_account_name" {
  description = "Name of the Kubernetes ServiceAccount this role is scoped to."
  type        = string
  default     = "bank-of-anthos"
}
