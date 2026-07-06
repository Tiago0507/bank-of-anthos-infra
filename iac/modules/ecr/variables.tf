variable "repository_names" {
  description = "Names of the ECR repositories to create, one per container image built by this project."
  type        = set(string)
}
