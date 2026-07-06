variable "vpc_cidr" {
  description = "CIDR (Classless Inter-Domain Routing) block for the VPC (Virtual Private Cloud): the overall private address range for this network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR (Classless Inter-Domain Routing) blocks for the public subnets, one per AZ (Availability Zone)."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR (Classless Inter-Domain Routing) blocks for the private subnets, one per AZ (Availability Zone)."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "cluster_name" {
  description = "Name of the EKS (Elastic Kubernetes Service) cluster that will use this network. Used only to tag subnets (kubernetes.io/cluster/<name>) so EKS and the AWS Load Balancer Controller can discover them; the EKS cluster itself is created by a separate module."
  type        = string
}
