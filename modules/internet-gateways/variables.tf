variable "vpc_id" {
  type = string
  description = "The ID of the VPC where the Internet Gateway will be attached."
}
variable "igw_name" {
   description = "The name tag for the Internet Gateway."
   type = string
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
