# Reads the real TLS (Transport Layer Security) certificate served by
# GitHub's own OIDC (OpenID Connect) issuer, so its thumbprint (a
# fingerprint of the certificate) can be used below instead of being typed
# in by hand. Same reasoning as the cluster's own OIDC provider in the eks
# module: a hardcoded thumbprint would go stale silently if the certificate
# is ever rotated.
data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

# Registers GitHub Actions as a second, separate identity source that IAM
# (Identity and Access Management) trusts. Separate from the EKS (Elastic
# Kubernetes Service) cluster's own OIDC provider created in the eks
# module: that one identifies Pods running inside the cluster; this one
# identifies workflow runs in GitHub, a completely different issuer.
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

# Trust policy for the role GitHub Actions assumes. Two conditions narrow
# down who can use it, the same least-privilege-at-the-condition-level idea
# already used in the irsa module:
#
# - aud confirms the token was issued for use with AWS STS (Security Token
#   Service), not some other audience.
# - sub confirms the token came from a run of this exact repository on
#   this exact ref. GitHub fills this claim in server-side, based on the
#   real trigger of the workflow run, not on anything the workflow's own
#   YAML claims about itself. This is what stops a run triggered from a
#   pull_request (whose sub claim would say "pull_request", not
#   "ref:refs/heads/main") from ever obtaining credentials here, even if
#   that pull_request's diff modified the workflow file itself to remove
#   the "only push to main logs into AWS" logic.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:ref:${var.allowed_ref}"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-ci-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

# Permission policy: only the ECR (Elastic Container Registry) actions
# needed to push an image, scoped to the 9 repositories already created by
# the ecr module. GetAuthorizationToken must use Resource = "*": AWS
# requires that for this specific action, since it grants a login token for
# the whole registry rather than for one repository.
data "aws_iam_policy_document" "ecr_push" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
    ]
    resources = var.ecr_repository_arns
  }
}

resource "aws_iam_role_policy" "ecr_push" {
  name   = "ecr-push"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.ecr_push.json
}
