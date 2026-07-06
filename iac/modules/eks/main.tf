# A "trust policy": says WHO is allowed to assume this IAM (Identity and
# Access Management) role, as opposed to a permission policy, which says
# WHAT that role is allowed to do once assumed. Here, the EKS (Elastic
# Kubernetes Service) service itself is the one allowed to assume it.
#
# "aws_iam_policy_document" is a data source specific to the AWS provider
# for building IAM policy JSON from structured blocks ("statement",
# "principals") instead of writing raw JSON with jsonencode(). It exists
# because IAM policies follow a very specific grammar (Effect, Action,
# Resource, Principal, Condition); this data source models that grammar
# directly and catches mistakes that a plain jsonencode() call would not.
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

# AWS-managed permission policy: lets the EKS (Elastic Kubernetes Service)
# control plane manage resources on this account's behalf (creating the
# ENIs -Elastic Network Interfaces- it needs inside the VPC -Virtual
# Private Cloud-, for example).
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)

    # Public: reachable from any IP, so kubectl works directly from a home
    # connection without a VPN. Reaching the endpoint still requires a
    # valid AWS IAM (Identity and Access Management) credential mapped to
    # an authorized identity; without one, requests are rejected regardless
    # of network reachability.
    endpoint_public_access = true

    # Private: lets traffic that originates inside the VPC (Virtual
    # Private Cloud) itself, such as the worker nodes talking to the API
    # server, stay on AWS's internal network instead of round-tripping
    # through the public internet.
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# Reads the real TLS (Transport Layer Security) certificate served by this
# specific cluster's OIDC (OpenID Connect) issuer endpoint, so its
# thumbprint (a fingerprint of the certificate) can be used below instead
# of being typed in by hand.
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Registers this cluster's OIDC (OpenID Connect) issuer with IAM (Identity
# and Access Management), which is what makes IRSA (IAM Roles for Service
# Accounts) possible in the next module: without this, IAM has no way to
# trust tokens issued by this specific cluster.
resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

# Trust policy for the node role: EC2 (Elastic Compute Cloud) instances are
# the ones allowed to assume it, since the worker nodes are EC2 instances.
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# Three AWS-managed permission policies a worker node needs: join and be
# managed by the cluster, run the CNI (Container Network Interface) plugin
# that assigns Pod IPs, and pull images from ECR (Elastic Container
# Registry).
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = [var.node_instance_type]

  # ON_DEMAND over SPOT: reliable for a short verification session: AWS
  # cannot reclaim an ON_DEMAND instance mid-session the way it can a Spot
  # instance (with only a 2-minute warning).
  capacity_type = "ON_DEMAND"

  scaling_config {
    min_size     = var.node_count
    max_size     = var.node_count
    desired_size = var.node_count
  }

  # EKS (Elastic Kubernetes Service) requires the node role's policies to
  # already be attached before nodes can successfully join the cluster;
  # without this, node creation can fail or nodes can join in a broken
  # state.
  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_readonly,
  ]
}
