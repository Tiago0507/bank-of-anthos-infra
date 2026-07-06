variable "cluster_name" {
  description = "Name of the EKS (Elastic Kubernetes Service) cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS (Elastic Kubernetes Service) control plane. AWS periodically stops supporting old versions; check the current supported list in the AWS console before applying."
  type        = string
  default     = "1.31"
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets where the EC2 (Elastic Compute Cloud) worker nodes are placed."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets, passed to the EKS (Elastic Kubernetes Service) control plane alongside the private ones, following the standard reference setup."
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 (Elastic Compute Cloud) instance type for the worker nodes. Must be Free Tier eligible for this account (verified with 'aws ec2 describe-instance-types --filters Name=free-tier-eligible,Values=true'); this account's Free Plan rejects any other instance type at node group creation time."
  type        = string
  default     = "m7i-flex.large"
}

variable "node_count" {
  description = "Fixed number of EC2 (Elastic Compute Cloud) worker nodes (min, max, and desired size are all set to this same value; no autoscaling for this learning project)."
  type        = number
  default     = 2
}
