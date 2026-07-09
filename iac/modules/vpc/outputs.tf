output "vpc_id" {
  description = "ID of the VPC (Virtual Private Cloud), needed by the EKS (Elastic Kubernetes Service) module."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ (Availability Zone)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ (Availability Zone). EKS (Elastic Kubernetes Service) worker nodes are placed here."
  value       = aws_subnet.private[*].id
}
