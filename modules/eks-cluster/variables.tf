variable "subnet_ids" {
  type = list(string)
  description = "List of private subnet IDs"
}
variable "eks_cluster_name" {
    type = string
    description = "Name of the EKS Cluster"
}
variable "cluster_version" {
  type = string
  description = "EKS Cluster Version"
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
variable "instance_types" {
  type = list(string)
  description = "Instance type of EKS node Group"
}
variable "default_nodegroup_ami_type" {
  type = string
  description = "AMI Type of Nodes"
}
variable "desired_size" {
  type = number
  description = "Desired Size of the EKS Node Group"
}
variable "max_size" {
  type = number
  description = "Maximum Size of EKS Node Group"
}
variable "min_size" {
  type = number
  description = "Minmum Size of EKS Node Group"
}
variable "eks_node_group_name" {
  type = string
  description = "Name of the EKS Cluster Node Group"
}
variable "disk_size" {
  type = number
  description = "EKS Node's Disk Size"
}
variable "max_unavailable" {
  type = number
  description = "max number of unavailable worker nodes during node group update"
}
variable "endpoint_private_access" {
  description = "Enable private access to the EKS cluster endpoint"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public access to the EKS cluster endpoint"
  type        = bool
}
variable "public_access_cidrs" {
  description = "List of allowed IPs to access EKS cluster"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region of csi-secret-driver"
  type        = string
}


variable "namespaces" {
  description = "List of namespace names to create"
  type        = list(string)
  default     = ["ghostcms", "karpenter", "redis"]
}

variable "vpc_id" {
  description = "VPC ID for the ALB Controller"
}