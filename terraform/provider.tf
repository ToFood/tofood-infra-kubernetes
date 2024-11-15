terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" 
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" 
    }
  }

  required_version = ">= 1.0.0" 
}

provider "aws" {
  region = var.region 
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.tofood_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.tofood_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.tofood_cluster.certificate_authority.0.data)
}
