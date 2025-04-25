
variable "vpc_name" {
  type = string
  description = "The name of the vpc network"
}
variable "region" {
  type = string
  description = "The name of the default region"
}
variable "vpc_cidr" {
  type = string
  description = "CIDR range of the VPC"
}

variable "private_subnet_cidr_1" {
  type = string
  description = "CIDR of private_subnet_cidr_1"
}
variable "private_subnet_cidr_2" {
    type = string
    description = "CIDR of private_subnet_cidr_2"
}
variable "public_subnet_cidr_1" {
    type = string
    description = "CIDR of public_subnet_cidr_1"
}
variable "public_subnet_cidr_2" {
    type = string
    description = "CIDR of public_subnet_cidr_2"
}


variable "nat_gateway_name" {
  type = string
  description = "name of the nat gateway"
}

variable "eks_cluster_name" {
  type = string
  description = "EKS Cluster name"
}


variable "db_private_subnet_cidr_1" {
  type = string
  description = "CIDR of private_subnet_cidr_1"
}

variable "db_private_subnet_cidr_2" {
    type = string
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


# locals {
#   ghostcms_tags = {
#     created_by    = "manan_g"
#     environment   = "jenkins"
#     maintained_by = "manan_g"
#     owner         = "trezix"
#     sensitive     = "no"
#     tenant        = "jenkins"
#   }
# }


# locals {
#   ghostcms_tags = {
#     created_by    = "manan_g"
#     environment   = "vpn"
#     maintained_by = "manan_g"
#     owner         = "trezix"
#     sensitive     = "no"
#     tenant        = "vpn"
#   }
# }


# locals {
#   ghostcms_tags = {
#     created_by    = "manan_g"
#     environment   = "monitoring"
#     maintained_by = "manan_g"
#     owner         = "trezix"
#     sensitive     = "no"
#     tenant        = "monitoring"
#   }
# }


# variable "vpn_vpc_name" {
#   type = string
# }


# variable "vpn_vpc_cidr" {
#   type = string
#   description = "CIDR range of the VPC"
# }
# # variable "nat_gateway_name" {
# #   type = string
# #   description = "NAT Gateway Name"
# # }

# variable "vpn_private_subnet_cidr_1" {
#   type = string
#   description = "CIDR of private_subnet_cidr_1"
# }
# variable "vpn_private_subnet_cidr_2" {
#     type = string
#     description = "CIDR of private_subnet_cidr_2"
# }
# variable "vpn_public_subnet_cidr_1" {
#     type = string
#     description = "CIDR of public_subnet_cidr_1"
# }
# variable "vpn_public_subnet_cidr_2" {
#     type = string
#     description = "CIDR of public_subnet_cidr_2"
# }



# ## monitoring vpc

# # variable "monit_vpc_name" {
# #   type = string
# #   description = "The name of the vpc network"
# # }

# # variable "monit_vpc_cidr" {
# #   type = string
# #   description = "CIDR range of the VPC"
# # }
# # # variable "nat_gateway_name" {
# # #   type = string
# # #   description = "NAT Gateway Name"
# # # }

# # variable "monit_private_subnet_cidr_1" {
# #   type = string
# #   description = "CIDR of private_subnet_cidr_1"
# # }
# # variable "monit_private_subnet_cidr_2" {
# #     type = string
# #     description = "CIDR of private_subnet_cidr_2"
# # }
# # variable "monit_public_subnet_cidr_1" {
# #     type = string
# #     description = "CIDR of public_subnet_cidr_1"
# # }
# # variable "monit_public_subnet_cidr_2" {
# #     type = string
# #     description = "CIDR of public_subnet_cidr_2"
# # }

# # variable "monit_nat_gateway_name" {
# #   type = string
# #   description = "name of the nat gateway"
# # }