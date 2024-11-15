# Declaração do Cluster EKS
resource "aws_eks_cluster" "tofood_cluster" {
  name     = "tofood-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.tofood_subnets[*].id
  }

  tags = {
    Name = "tofood-eks-cluster"
  }
}

# Role do Cluster EKS
resource "aws_iam_role" "eks_role" {
  name = "tofood-eks-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

# Política de Assunção do Cluster
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Grupo de Nós Gerenciados do EKS
resource "aws_eks_node_group" "tofood_node_group" {
  cluster_name    = aws_eks_cluster.tofood_cluster.name
  node_group_name = "tofood-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.tofood_subnets[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  tags = {
    Name = "tofood-node-group"
  }

  # Configuração para evitar problemas com a criação dos nós
  ami_type = "AL2_x86_64" # Certifique-se de usar a AMI correta para Kubernetes
  disk_size = 20          # Tamanho em GB
}

# Role dos Nós Gerenciados do EKS
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

# Políticas Anexadas ao Role dos Nós
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

# Dados do Cluster EKS para Configuração do Kubernetes Provider
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.tofood_cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.tofood_cluster.name
}
