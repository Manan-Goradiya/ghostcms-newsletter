variable "subnet_id" {
  description = "Subnet id of subnet to connect with nat gateway"
  type = string
}
variable "name" {
  description = "Name of the NAT gateway"
  type = string
}
variable "tags" {
  type        = map(string)
  description = "Labels to be added to the resource"
}
# variable "alloaction_id" {
#   type = string
#   description = "Elastic IP address alloaction_id required to attach with NAT Gateway, Create EIP from console"
# }
