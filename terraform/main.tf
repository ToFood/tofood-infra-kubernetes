# Terraform Configuration
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

# Providers
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.tofood_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.tofood_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.tofood_cluster.certificate_authority.0.data)
  depends_on             = [aws_eks_cluster.tofood_cluster]
}

# Variables
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "tofood-eks-cluster"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = "034362063771" # Substitua pelo seu ID de conta AWS
}

variable "image_name" {
  description = "Docker image name"
  default     = "tofood/backend"
}

variable "custom_aws_account_id" {
  description = "AWS Account ID do principal que pode assumir essa role"
  default     = "034362063771" # Substitua pelo ID da conta apropriado
}

# IAM Role para EKS Cluster
resource "aws_iam_role" "eks_default_role" {
  name = "AmazonEKS_DefaultRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Anexando política AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "eks_default_role_policy" {
  role       = aws_iam_role.eks_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Adição de outra política para gerenciamento de recursos de VPC pelo EKS
resource "aws_iam_role_policy_attachment" "eks_default_vpc_policy" {
  role       = aws_iam_role.eks_default_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}


# VPC Configuration
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "tofood_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tofood-vpc"
  }
}

resource "aws_subnet" "tofood_subnets" {
  count             = 3
  vpc_id            = aws_vpc.tofood_vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "tofood-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "tofood_igw" {
  vpc_id = aws_vpc.tofood_vpc.id
  tags = {
    Name = "tofood-igw"
  }
}

resource "aws_route_table" "tofood_route_table" {
  vpc_id = aws_vpc.tofood_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tofood_igw.id
  }

  tags = {
    Name = "tofood-route-table"
  }
}

resource "aws_route_table_association" "tofood_route_table_association" {
  count          = 3
  subnet_id      = aws_subnet.tofood_subnets[count.index].id
  route_table_id = aws_route_table.tofood_route_table.id
}

# EKS Cluster
resource "aws_eks_cluster" "tofood_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_default_role.arn

  vpc_config {
    subnet_ids = aws_subnet.tofood_subnets[*].id
  }

  tags = {
    Name = "tofood-eks-cluster"
  }
}

data "aws_eks_cluster" "tofood_cluster" {
  name = aws_eks_cluster.tofood_cluster.name
}

data "aws_eks_cluster_auth" "tofood_cluster" {
  name = aws_eks_cluster.tofood_cluster.name
}

# Kubernetes Namespace
resource "kubernetes_namespace" "tofood" {
  metadata {
    name = "tofood"
  }
}

# Kubernetes Deployment
resource "kubernetes_deployment" "tofood_app" {
  metadata {
    name      = "tofood-app"
    namespace = kubernetes_namespace.tofood.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "tofood"
      }
    }

    template {
      metadata {
        labels = {
          app = "tofood"
        }
      }

      spec {
        container {
          name  = "tofood-container"
          image = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.image_name}:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Kubernetes Service
resource "kubernetes_service" "tofood_app_service" {
  metadata {
    name      = "tofood-service"
    namespace = kubernetes_namespace.tofood.metadata[0].name
  }

  spec {
    selector = {
      app = "tofood"
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
    }
  }
}

# Outputs
output "cluster_endpoint" {
  value       = aws_eks_cluster.tofood_cluster.endpoint
  description = "Endpoint do Cluster EKS"
}

output "tofood_service_url" {
  value       = kubernetes_service.tofood_app_service.status[0].load_balancer[0].ingress[0].hostname
  description = "URL do Serviço ToFood"
}
