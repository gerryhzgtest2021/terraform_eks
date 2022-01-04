locals {
  aws_region = "us-east-1"
  env        = "test"
}

provider "aws" {
  region = local.aws_region
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  azs                  = ["us-east-1a", "us-east-1b"]
  name                 = "${local.env}-vpc"
  private_subnets      = ["10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.0.0/24", "10.0.1.0/24"]
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_classiclink   = false
  enable_nat_gateway   = true
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_version = "1.21"
  cluster_name    = "${local.env}-cluster"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets

  worker_groups = [
    {
      instance_type = "t2.micro"
      asg_max_size  = 5
    }
  ]
}
