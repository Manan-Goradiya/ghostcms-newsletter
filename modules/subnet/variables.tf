variable "vpc_id" {
  type = string
  description = "VPC_ID of the vpc network where subnet belongs"
}
variable "subnet-cidr" {
  type = string
  description = "CIDR of the Subnet"
}
variable "availability_zone" {
  type = string
  description = "Availability Zone of the subnet"
}
variable "subnet_name" {
  type = string
  description = "Name of the Subnet"
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
variable "map_public_ip_on_launch" {
  type = bool
  description = "Specify whether to enable automatic public IP assignment for instances launched in this subnet (true/false)"
}