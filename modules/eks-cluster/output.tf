output "cluster_security_group_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}


output "cluster_provider_url" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "oidc_provider_arn" {
  value = "arn:aws:iam::${aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer}"
}
output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}