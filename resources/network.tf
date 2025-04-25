module "vpc" {
  source = "../modules/network/"
  vpc_name =  var.vpc_name
  vpc_cidr = var.vpc_cidr
  tags = local.ghostcms_tags
}
module "private-subnet-ap-south-1a" {
  depends_on = [ module.vpc ]
  vpc_id = module.vpc.vpc_id
  source = "../modules/subnet"
  availability_zone = "ap-south-1a"
  subnet-cidr = var.private_subnet_cidr_1
  subnet_name = "private-subnet-ap-south-1a"
    tags = local.ghostcms_tags
  map_public_ip_on_launch = false
}


module "private-subnet-ap-south-1b" {
  depends_on = [ module.vpc ]
  vpc_id = module.vpc.vpc_id
  source = "../modules/subnet"
  availability_zone = "ap-south-1b"
  subnet-cidr = var.private_subnet_cidr_2
  subnet_name = "private-subnet-ap-south-1b"
    tags = local.ghostcms_tags
  map_public_ip_on_launch = false
}
module "public-subnet-ap-south-1a" {
  depends_on = [ module.vpc ]
  vpc_id = module.vpc.vpc_id
  source = "../modules/subnet"
  availability_zone = "ap-south-1a"
  subnet-cidr = var.public_subnet_cidr_1
  subnet_name = "public-subnet-ap-south-1a"
    tags = merge(local.ghostcms_tags,
      {

      "kubernetes.io/role/elb" = "1"
      } )
  map_public_ip_on_launch = true
}
module "public-subnet-ap-south-1b" {
  depends_on = [ module.vpc ]
  vpc_id = module.vpc.vpc_id
  source = "../modules/subnet"
  availability_zone = "ap-south-1b"
  subnet-cidr = var.public_subnet_cidr_2
  subnet_name = "public-subnet-ap-south-1b"
    tags = merge(local.ghostcms_tags,
      {
      "kubernetes.io/role/elb" = "1"
      } )
  map_public_ip_on_launch = true
}


# Additional private subnets for DBs
module "db-private-subnet-ap-south-1a" {
  depends_on = [ module.vpc ]
  vpc_id = module.vpc.vpc_id
  source = "../modules/subnet"
  availability_zone = "ap-south-1a"
  subnet-cidr = var.db_private_subnet_cidr_1
  subnet_name = "db-private-subnet-ap-south-1a"
    tags = local.ghostcms_tags
  
  map_public_ip_on_launch = false
}

module "db-private-subnet-ap-south-1b" {
  depends_on = [ module.vpc ]
  vpc_id = module.vpc.vpc_id
  source = "../modules/subnet"
  availability_zone = "ap-south-1b"
  subnet-cidr = var.db_private_subnet_cidr_2
  subnet_name = "db-private-subnet-ap-south-1b"
    tags = local.ghostcms_tags
  map_public_ip_on_launch = false
}







module "internet_gateway" {
  source = "../modules/internet-gateways"
  depends_on = [ module.vpc ]
  vpc_id   = module.vpc.vpc_id  # Replace with your actual VPC module output
  igw_name = "ghostcms-internet-gateway"
  tags = local.ghostcms_tags
}


# ## VPN VPC

# module "vpn_vpc" {
#   source = "../modules/network/"
#   vpc_name =  var.vpn_vpc_name
#   vpc_cidr = var.vpn_vpc_cidr
#   tags = local.ghostcms_tags
# }
# module "vpn-private-subnet-ap-south-1a" {
#   depends_on = [ module.vpn_vpc ]
#   vpc_id = module.vpn_vpc.vpc_id
#   source = "../modules/subnet"
#   availability_zone = "ap-south-1a"
#   subnet-cidr = var.vpn_private_subnet_cidr_1
#   subnet_name = "tz-vpn-subnet-private1-ap-south-1a"
#   tags = local.ghostcms_tags
#   map_public_ip_on_launch = false
# }


# module "vpn-private-subnet-ap-south-1b" {
#   depends_on = [ module.vpn_vpc ]
#   vpc_id = module.vpn_vpc.vpc_id
#   source = "../modules/subnet"
#   availability_zone = "ap-south-1b"
#   subnet-cidr = var.vpn_private_subnet_cidr_2
#   subnet_name = "tz-vpn-subnet-private2-ap-south-1b"
#   tags = local.ghostcms_tags
#   map_public_ip_on_launch = false
# }
# module "vpn-public-subnet-ap-south-1a" {
#   depends_on = [ module.vpn_vpc ]
#   vpc_id = module.vpn_vpc.vpc_id
#   source = "../modules/subnet"
#   availability_zone = "ap-south-1a"
#   subnet-cidr = var.vpn_public_subnet_cidr_1
#   subnet_name = "tz-vpn-subnet-public1-ap-south-1a"
#   tags = local.ghostcms_tags
#   map_public_ip_on_launch = true
# }
# module "vpn-public-subnet-ap-south-1b" {
#   depends_on = [ module.vpn_vpc ]
#   vpc_id = module.vpn_vpc.vpc_id
#   source = "../modules/subnet"
#   availability_zone = "ap-south-1b"
#   subnet-cidr = var.vpn_public_subnet_cidr_2
#   subnet_name = "tz-vpn-subnet-public2-ap-south-1b"
#   tags = local.ghostcms_tags
#   map_public_ip_on_launch = true
# }

# module "vpn_internet_gateway" {
#   source = "../modules/internet-gateways"
#   depends_on = [ module.vpn_vpc ]
#   vpc_id   = module.vpn_vpc.vpc_id  # Replace with your actual VPC module output
#   igw_name = "tz-vpn-igw"
#   tags = local.ghostcms_tags
# }
