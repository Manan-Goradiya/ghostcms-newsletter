variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "routes" {
  type = list(object({
    cidr_block     = string
    gateway_id     = optional(string)
    nat_gateway_id = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
}

variable "tags" {
  type = map(string)
}
