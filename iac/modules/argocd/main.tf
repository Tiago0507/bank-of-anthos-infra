# Installs ArgoCD itself into its own namespace, via the project's
# official Helm chart. create_namespace = true means Terraform creates
# the "argocd" namespace as part of this release, instead of requiring it
# to already exist.
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = "argocd"
  create_namespace = true
}

# Repository credential for bank-of-anthos-gitops, using the GitHub App
# credential type ArgoCD supports natively: ArgoCD exchanges the App's
# private key for its own short-lived tokens whenever it needs to clone
# the repo, so no static PAT (Personal Access Token) or SSH key is stored
# here. The argocd.argoproj.io/secret-type label is how ArgoCD discovers
# this Secret as a repository credential; it does not need to be
# referenced anywhere else, including from the Application resource
# below.
resource "kubernetes_secret" "gitops_repo_credentials" {
  metadata {
    name      = "bank-of-anthos-gitops-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type                    = "git"
    url                     = "https://github.com/${var.github_org}/bank-of-anthos-gitops"
    githubAppID             = var.gitops_reader_app_id
    githubAppInstallationID = var.gitops_reader_installation_id
    githubAppPrivateKey     = var.gitops_reader_private_key
  }

  depends_on = [helm_release.argocd]
}

# One Application per environment this installation manages (dev+staging
# for the shared nonprod cluster, just prod for the dedicated prod
# cluster). depends_on is required here, not just implied by a reference:
# kubernetes_manifest has no other way to know the Application CRD
# (Custom Resource Definition, what teaches Kubernetes this resource type
# even exists) is only installed once the Helm release above finishes,
# since nothing in this resource's own arguments points back to
# helm_release.argocd.
resource "kubernetes_manifest" "applications" {
  for_each = var.environments

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "bank-of-anthos-${each.key}"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/${var.github_org}/bank-of-anthos-gitops"
        targetRevision = "main"
        path           = "overlays/${each.key}"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = each.key
      }

      # automated (vs. requiring a manual "Sync" click) matches the
      # existing decision that a push to main deploys without a manual
      # approval step. Revisit for prod once PR-based promotion between
      # environments is in place, if a manual approval gate is wanted
      # there.
      #
      # prune: removes cluster resources whose manifest was deleted from
      # the repo, keeping the cluster from accumulating orphans.
      #
      # selfHeal: reverts manual changes made directly against the
      # cluster (e.g. a stray kubectl edit) back to what git says, on the
      # next reconciliation loop — the enforcement mechanism behind "git
      # is the only source of truth".
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [helm_release.argocd, kubernetes_secret.gitops_repo_credentials]
}
