variable "efs_name" {
  description = "Name of the EFS file system"
  type        = string
}   

variable "security_group_vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "ghostcms_tags" {
  description = "Tags to apply to the EFS file system"
  type        = map(string)
  default     = {}
}

variable "private_subnet_1_id" {
  description = "ID of the first private subnet"
  type        = string     
}

variable "private_subnet_2_id" {
  description = "ID of the second private subnet"
  type        = string
}