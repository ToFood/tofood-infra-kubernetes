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

resource "aws_iam_role" "eks_role" {
  name = "tofood-eks-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
