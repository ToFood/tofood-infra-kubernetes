terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # Ajuste para a versão desejada
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" # Ajuste para a versão desejada
    }
  }

  required_version = ">= 1.0.0" # Ajuste conforme a versão mínima do Terraform que deseja suportar
}

provider "aws" {
  region = var.region # Usa a variável 'region' definida em 'variables.tf'
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
