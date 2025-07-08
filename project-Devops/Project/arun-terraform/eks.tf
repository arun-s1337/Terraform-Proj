provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-subnet"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"

  cluster_name    = "arun-eks-cluster"
  cluster_version = "1.28"
  subnet_ids      = [aws_subnet.public.id, aws_subnet.private.id]
  vpc_id          = aws_vpc.main.id

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    dev = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  }

  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
    "UserId": "AIDA4PVPBMS7HMNY4WHKV",
    "Account": "858286810302",
    "Arn": "arn:aws:iam::858286810302:user/personal-proj"
  } 

  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }


