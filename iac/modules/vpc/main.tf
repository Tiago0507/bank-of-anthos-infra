# Live list of AZs (Availability Zones) available in this account and
# region, instead of hardcoding names like "us-east-1a". AZ (Availability
# Zone) names map to different physical data centers per AWS account, so a
# hardcoded name is not portable across accounts.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  # Both required by EKS (Elastic Kubernetes Service): nodes and Pods need
  # to resolve DNS names, and EC2 instances need an internal DNS hostname.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# IGW (Internet Gateway): connects the VPC (Virtual Private Cloud) to the
# public internet. Without it, no subnet, public or private, has any path
# in or out.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# Public subnets, one per AZ (Availability Zone). "count" pairs position N
# of the AZ list with position N of the CIDR (Classless Inter-Domain
# Routing) list; both lists are already in the intended order, so numeric
# pairing is simpler here than "for_each" with a synthetic key.
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${count.index}"
    # Tells the AWS Load Balancer Controller this subnet is a candidate for
    # an internet-facing ELB (Elastic Load Balancer, e.g. the NLB in front
    # of the frontend Service).
    "kubernetes.io/role/elb" = "1"
    # Tells EKS (Elastic Kubernetes Service) and the AWS Load Balancer
    # Controller this subnet belongs to this specific cluster.
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Private subnets, one per AZ (Availability Zone). No
# "map_public_ip_on_launch": instances launched here never get a public IP.
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
    # Candidate subnet for an internal (non-internet-facing) ELB (Elastic
    # Load Balancer), if one is ever needed.
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# EIP (Elastic IP): a static public IP address, required by the NAT
# (Network Address Translation) Gateway below so it has a fixed address to
# use when reaching the internet on behalf of private subnets.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip"
  }
}

# A single NAT (Network Address Translation) Gateway, shared by both
# private subnets, chosen over one per AZ (Availability Zone) to keep cost
# down. A second NAT Gateway would add AZ-level fault isolation, at double
# the hourly cost; not worth it for infrastructure that gets torn down
# after each short session. Placed in the first public subnet, since a NAT
# Gateway itself needs a route to the internet through an IGW (Internet
# Gateway).
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.cluster_name}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

# Route table for public subnets: sends all non-VPC (Virtual Private
# Cloud) traffic (0.0.0.0/0) straight to the IGW (Internet Gateway).
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

# Route table for private subnets: sends all non-VPC (Virtual Private
# Cloud) traffic (0.0.0.0/0) through the NAT (Network Address Translation)
# Gateway instead, so instances can reach the internet outbound without
# being reachable from it.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}

# Associates each public subnet with the public route table. A subnet with
# no association would fall back to the VPC's (Virtual Private Cloud's)
# default route table, which has no route to the internet.
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
