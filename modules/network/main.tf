resource "aws_vpc" "vpc-network" {
  enable_dns_hostnames = true
tags = merge(
    var.tags, 
    {
      Name = var.vpc_name
    }
  )
  cidr_block = var.vpc_cidr
}
