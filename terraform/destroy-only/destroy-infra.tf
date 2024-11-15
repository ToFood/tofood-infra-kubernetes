# Declaração do recurso de dados para obter as zonas de disponibilidade
data "aws_availability_zones" "available" {
  state = "available"
}

# IAM Roles
resource "aws_iam_role" "eks_role" {
  name = "tofood-eks-role"
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

resource "aws_iam_role" "eks_node_role" {
  name = "tofood-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Políticas IAM para Roles dos Nós
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Cluster EKS
resource "aws_eks_cluster" "eks_cluster" {
  name     = "tofood-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }
}

# Node Group do EKS
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "tofood-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  ami_type       = "AL2_x86_64" # Tipo de AMI para EKS
}

# Security Group associado ao EKS
resource "aws_security_group" "eks_sg" {
  name   = "tofood-eks-sg"
  vpc_id = aws_vpc.eks_vpc.id
}

# VPC e Subnets
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tofood-vpc"
  }
}

resource "aws_subnet" "eks_subnets" {
  count             = 3
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "tofood-subnet-${count.index}"
  }
}

# Load Balancer
resource "aws_lb" "eks_lb" {
  name               = "eks-auto-lb"
  load_balancer_type = "application"
  subnets            = aws_subnet.eks_subnets[*].id
}

# Instâncias EC2 Residuais
resource "aws_instance" "ec2_instances" {
  ami           = "ami-12345678" # Substitua com uma AMI válida
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.eks_subnets[0].id
}

# Bucket S3 Residual
resource "aws_s3_bucket" "eks_s3_bucket" {
  bucket        = "tofood-eks-residual-bucket"
  force_destroy = true
}

# Elastic File System (EFS) Residual
resource "aws_efs_file_system" "efs_cleanup" {
  creation_token = "tofood-efs-cleanup"
}
