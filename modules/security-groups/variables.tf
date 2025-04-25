variable "security_group_name" {
  type = string
  description = "Security Group Name"
}
variable "description" {
  type = string 
  description = "Security Group Description"
}
variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
variable "rules" {
  type = list(object({
    type                     = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}
