provider "aws" {
  region = "us-west-2"
}

# Import the VPC and subnets
module "vpc" {
  source = "./vpc.tf"
}

# Import EKS Cluster Configuration
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "devops-cluster"
  cluster_version = "1.21"
  subnets         = module.vpc.subnets
  node_groups = {
    eks_node_group = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.micro"
    }
  }
}

# CloudFront configuration for edge delivery
module "cloudfront" {
  source = "./cloudfront.tf"
}

# Security configurations (IAM roles, Lambda execution, etc.)
module "security" {
  source = "./security.tf"
}
