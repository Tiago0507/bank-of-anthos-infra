# One repository per name in var.repository_names, instead of nine nearly
# identical resource blocks copy-pasted by hand. Inside the block, each.value
# is the current name from the set being iterated.
resource "aws_ecr_repository" "this" {
  for_each = var.repository_names

  name = each.value

  # IMMUTABLE rejects a push that reuses a tag already present in the
  # repository, so a tag always points to exactly one image. Left as
  # MUTABLE while images were pushed by hand and reused the "latest" tag
  # repeatedly; switched once the CI pipeline started tagging every image
  # by commit SHA, since a unique tag per build removes the friction
  # MUTABLE existed to avoid.
  image_tag_mutability = "IMMUTABLE"

  # Free vulnerability scan on every image pushed to this repository. Does
  # not replace the Trivy scan planned for the CI pipeline; it is an
  # additional check that also covers images pushed manually, outside CI.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Allows "terraform destroy" to remove the repository even if it still
  # contains images. Needed because this project intentionally destroys
  # infrastructure after each short working session, images included.
  force_delete = true
}

# Automatically expires untagged images after 7 days. An image becomes
# untagged when a tag that used to point to it is moved to point at a newer
# image (expected here, since the repositories use MUTABLE tags). Without
# this policy, those orphaned images would stay in the repository, and in
# ECR forever, taking up storage with no way to reference them again.
resource "aws_ecr_lifecycle_policy" "untagged_expiry" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
