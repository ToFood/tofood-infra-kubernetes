output "cluster_endpoint" {
  value       = aws_eks_cluster.tofood_cluster.endpoint
  description = "Endpoint do Cluster EKS"
}

output "cluster_name" {
  value       = aws_eks_cluster.tofood_cluster.name
  description = "Nome do Cluster EKS"
}
