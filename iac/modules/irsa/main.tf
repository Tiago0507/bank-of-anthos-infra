# Trust policy for IRSA (IAM Roles for Service Accounts). Different from
# the trust policies in the EKS (Elastic Kubernetes Service) module: those
# trusted an AWS service directly ("Service" principal); this one trusts
# identities federated through this cluster's OIDC (OpenID Connect)
# provider instead ("Federated" principal), and the action is
# "sts:AssumeRoleWithWebIdentity" rather than the plain "sts:AssumeRole"
# used for a Service principal.
#
# Without the condition block below, ANY Pod in the cluster, running under
# any ServiceAccount, could assume this role: the OIDC provider is trusted
# for the whole cluster, not for one specific ServiceAccount. The
# condition is what narrows "any Pod in this cluster" down to "only Pods
# running under this exact namespace and ServiceAccount name" — the same
# least-privilege-at-the-file-level idea already used for the JWT
# (JSON Web Token) public/private key split.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    # OIDC condition keys use the issuer host and path without the
    # "https://" prefix; trimprefix() removes exactly that prefix (unlike
    # replace(), which would remove the text anywhere it appears in the
    # string, not only at the start).
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.oidc_provider_url, "https://")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    # A second condition, checked in addition to the first: confirms the
    # token was actually issued for use with AWS STS (Security Token
    # Service), not for some other, unrelated audience.
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(var.oidc_provider_url, "https://")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.cluster_name}-${var.service_account_name}-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json

  # Intentionally no permission policy attached yet: today, no code in
  # this application calls any AWS API directly (the JWT signing key
  # still lives in a plain Kubernetes Secret). This role only proves the
  # ServiceAccount can authenticate as itself; real permissions get
  # attached once there is something concrete to grant (moving the JWT
  # key to Secrets Manager).
}
