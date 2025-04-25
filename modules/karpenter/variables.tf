variable "cluster_name" {
  description = "Name of EKS cluster"
  type = string
}

variable "karpenter_namespace" {
  description = "The K8S namespace to deploy Karpenter into"
  default     = "karpenter"
  type        = string
}

variable "AMI_ID" {
  description = "AMI ID for EKS worker nodes"
  type = string
  default = ""
}

variable "cluster_endpoint" {
  type = string
}

variable "role_name" {
  type = string
}

variable "provider_url" {
  type = string
}

variable "karpenter_policy_name" {
  type = string
}