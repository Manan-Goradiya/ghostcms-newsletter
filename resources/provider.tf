terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }

  }
}


provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--profile", "manan-devops"]
      command     = "aws"
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

provider "kubectl" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--profile", "manan-devops"]
    command     = "aws"
  }
}