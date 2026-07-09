module "ecr" {
  source = "../../modules/ecr"

  repository_names = var.ecr_repository_names
}

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

module "github_oidc" {
  source = "../../modules/github-oidc"

  github_org          = var.github_org
  github_repo         = var.github_repo
  ecr_repository_arns = values(module.ecr.repository_arns)
}

module "argocd" {
  source = "../../modules/argocd"

  github_org                    = var.github_org
  gitops_reader_app_id          = var.gitops_reader_app_id
  gitops_reader_installation_id = var.gitops_reader_installation_id
  gitops_reader_private_key     = var.gitops_reader_private_key
}
