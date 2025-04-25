variable "region" {
  type        = string
  description = "Name of the region to select"
}

variable "cluster_oidc_issuer_url" {
  description = ""
  type        = string
}

variable "oidc_provider_arn" {
  description = ""
  type        = string
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_endpoint" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_certificate_authority_data" {
  type        = string
  description = "Name of the EKS cluster"
}
