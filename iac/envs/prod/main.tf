# No ecr or github_oidc module here: ECR (Elastic Container Registry) is
# account-wide, not per-cluster, and the CI never needs prod-specific AWS
# access (it only ever publishes to the one shared registry that
# envs/nonprod already created). Duplicating either here would conflict
# with (or pointlessly copy) what already exists there.

module "vpc" {
  source = "../../modules/vpc"

  cluster_name = var.cluster_name
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
}

module "irsa" {
  source = "../../modules/irsa"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "argocd" {
  source = "../../modules/argocd"

  environments                  = ["prod"]
  github_org                    = var.github_org
  gitops_reader_app_id          = var.gitops_reader_app_id
  gitops_reader_installation_id = var.gitops_reader_installation_id
  gitops_reader_private_key     = var.gitops_reader_private_key
}
