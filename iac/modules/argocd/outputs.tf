output "namespace" {
  description = "Kubernetes namespace where ArgoCD itself runs."
  value       = helm_release.argocd.namespace
}
