# IAM Roles que podem estar órfãos
resource "aws_iam_role" "eks_role" {
  name = "tofood-eks-role"
}

resource "aws_iam_role" "eks_node_role" {
  name = "tofood-eks-node-role"
}

# Políticas IAM anexadas aos Roles
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

# EKS Cluster e Grupos de Nós
resource "aws_eks_cluster" "eks_cluster" {
  name = "tofood-eks-cluster"
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "tofood-node-group"
}

# Security Groups associados ao EKS
resource "aws_security_group" "eks_sg" {
  name = "tofood-eks-sg"
}

# Sub-redes e VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "eks_subnets" {
  count      = 3
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
}

# Load Balancers (ELBs/ALBs) criados automaticamente pelo EKS
resource "aws_lb" "eks_lb" {
  name = "eks-auto-lb"
}

# Instâncias EC2 residuais
resource "aws_instance" "ec2_instances" {
  ami           = "ami-12345678" # Altere para uma AMI válida
  instance_type = "t2.micro"
}

# Buckets S3 residuais
resource "aws_s3_bucket" "eks_s3_bucket" {
  bucket        = "tofood-eks-residual-bucket"
  force_destroy = true # Remove os objetos antes de destruir o bucket
}

# EFS (Elastic File System) criados manualmente ou automaticamente
resource "aws_efs_file_system" "efs_cleanup" {
  creation_token = "tofood-efs-cleanup"
}
