module "public_route_table" {
  depends_on = [ module.vpc, module.private-subnet-ap-south-1a,module.private-subnet-ap-south-1b,module.public-subnet-ap-south-1a,module.public-subnet-ap-south-1b]
  source   = "../modules/route-table"
  vpc_id   = module.vpc.vpc_id
  name     = "ghostcms_tags-public-route-table"
  vpc_cidr = var.vpc_cidr
  subnet_ids = [ module.public-subnet-ap-south-1a.subnet_id, module.public-subnet-ap-south-1b.subnet_id ]
  
  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]
  
  tags = local.ghostcms_tags
}
module "private_route_table" {
  depends_on = [ module.vpc, module.private-subnet-ap-south-1a,module.private-subnet-ap-south-1b,module.public-subnet-ap-south-1a,module.public-subnet-ap-south-1b]
  source   = "../modules/route-table"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  name     = "ghostcms_tags-private-route-table"
  subnet_ids = [
    module.private-subnet-ap-south-1a.subnet_id,
    module.private-subnet-ap-south-1b.subnet_id
 
  ]
  
  routes = [
  #   {
  #   cidr_block     = "172.23.0.0/16"
  #   vpc_peering_connection_id = "pcx-0c49ece8dc53e1c6e"
  # }
  # ,
  {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.aws_nat_gateway.nat_gateway_id
  }

]
  
  tags = local.ghostcms_tags
}





# # VPN VPC

# module "vpn_public_route_table" {
#   depends_on = [ module.vpn_vpc, module.vpn-private-subnet-ap-south-1a,module.vpn-private-subnet-ap-south-1b,module.vpn-public-subnet-ap-south-1a,module.vpn-public-subnet-ap-south-1b]
#   source   = "../modules/route-table"
#   vpc_id   = module.vpn_vpc.vpc_id
#   name     = "tz-vpn-rtb-public"
#   vpc_cidr = var.vpn_vpc_cidr
#   subnet_ids = [ module.vpn-public-subnet-ap-south-1a.subnet_id, module.vpn-public-subnet-ap-south-1b.subnet_id ]
  
#   routes = [
#     {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = module.vpn_internet_gateway.internet_gateway_id
#     },
#     {
#       cidr_block = "172.22.0.0/16"
#       vpc_peering_connection_id = "pcx-0c49ece8dc53e1c6e"
#     }
#   ]
  
#   tags = local.ghostcms_tags
# }
# module "vpn_private_route_table" {
#   depends_on = [ module.vpn_vpc, module.vpn-private-subnet-ap-south-1a,module.vpn-private-subnet-ap-south-1b,module.vpn-public-subnet-ap-south-1a,module.vpn-public-subnet-ap-south-1b]
#   source   = "../modules/route-table"
#   vpc_id   = module.vpn_vpc.vpc_id
#   vpc_cidr = var.vpn_vpc_cidr
#   name     = "rtb-0bf8e2f3679ef72c0"
#   subnet_ids = [
#     module.vpn-private-subnet-ap-south-1a.subnet_id,
#     module.vpn-private-subnet-ap-south-1b.subnet_id
 
#   ]
  
#   routes = [
# ]
  
#   tags = local.ghostcms_tags
# }
