variable "github_org" {
  description = "GitHub organization or username that owns the repository allowed to assume this role."
  type        = string
}

variable "github_repo" {
  description = "Name of the GitHub repository allowed to assume this role."
  type        = string
}

variable "allowed_ref" {
  description = "Git ref (branch) allowed to assume this role, in the sub claim format GitHub issues (for example refs/heads/main). Only workflow runs triggered from this exact ref can obtain AWS credentials."
  type        = string
  default     = "refs/heads/main"
}

variable "ecr_repository_arns" {
  description = "ARNs (Amazon Resource Names) of the ECR repositories this role is allowed to push images to."
  type        = list(string)
}
