variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR range of the Whole VPC"
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
