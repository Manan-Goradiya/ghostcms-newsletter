
variable "vpc_name" {
  type        = string
  description = "The name of the vpc network"
}
variable "region" {
  type        = string
  description = "The name of the default region"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR range of the VPC"
}

variable "private_subnet_cidr_1" {
  type        = string
  description = "CIDR of private_subnet_cidr_1"
}
variable "private_subnet_cidr_2" {
  type        = string
  description = "CIDR of private_subnet_cidr_2"
}
variable "public_subnet_cidr_1" {
  type        = string
  description = "CIDR of public_subnet_cidr_1"
}
variable "public_subnet_cidr_2" {
  type        = string
  description = "CIDR of public_subnet_cidr_2"
}


variable "nat_gateway_name" {
  type        = string
  description = "name of the nat gateway"
}

variable "eks_cluster_name" {
  type        = string
  description = "EKS Cluster name"
}


variable "db_private_subnet_cidr_1" {
  type        = string
  description = "CIDR of private_subnet_cidr_1"
}

variable "db_private_subnet_cidr_2" {
  type        = string
  description = "CIDR of private_subnet_cidr_2"
}

locals {
  ghostcms_tags = {
    created_by    = "manan_g"
    environment   = "ghsotcms"
    maintained_by = "manan_g"
    owner         = "manan_g"
    sensitive     = "no"
    tenant        = "ghsotcms"
  }
}