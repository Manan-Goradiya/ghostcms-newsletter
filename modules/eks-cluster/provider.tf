terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}

# provider "kubectl" {
#   host                   = var.cluster_endpoint #aws_eks_cluster.eks_cluster.endpoint
#   cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file       = false
# }