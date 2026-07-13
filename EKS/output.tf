output "cluster_id" {
  value = aws_eks_cluster.obito.id
}

output "node_group_id" {
  value = aws_eks_node_group.obito.id
  }

output "vpc_id" {
  value = aws_vpc.obito_vpc.id
}

output "subnet_id" {
  value = aws_subnet.obito_subnet[*].id
}