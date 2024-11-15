output "cluster_endpoint" {
  value       = aws_eks_cluster.tofood_cluster.endpoint
  description = "Endpoint do Cluster EKS"
}

output "cluster_name" {
  value       = aws_eks_cluster.tofood_cluster.name
  description = "Nome do Cluster EKS"
}

output "node_role_arn" {
  value       = aws_iam_role.eks_node_role.arn
  description = "ARN do Role dos Nós do EKS"
}
