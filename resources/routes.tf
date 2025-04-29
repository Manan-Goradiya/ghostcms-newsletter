module "public_route_table" {
  depends_on = [module.vpc, module.private-subnet-ap-south-1a, module.private-subnet-ap-south-1b, module.public-subnet-ap-south-1a, module.public-subnet-ap-south-1b]
  source     = "../modules/route-table"
  vpc_id     = module.vpc.vpc_id
  name       = "ghostcms-public-route-table"
  vpc_cidr   = var.vpc_cidr
  subnet_ids = [module.public-subnet-ap-south-1a.subnet_id, module.public-subnet-ap-south-1b.subnet_id]

  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.internet_gateway.internet_gateway_id
    }
  ]

  tags = local.ghostcms_tags
}
module "private_route_table" {
  depends_on = [module.vpc, module.private-subnet-ap-south-1a, module.private-subnet-ap-south-1b, module.public-subnet-ap-south-1a, module.public-subnet-ap-south-1b]
  source     = "../modules/route-table"
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = var.vpc_cidr
  name       = "ghostcms-private-route-table"
  subnet_ids = [
    module.private-subnet-ap-south-1a.subnet_id,
    module.private-subnet-ap-south-1b.subnet_id

  ]

  routes = [

    {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = module.aws_nat_gateway.nat_gateway_id
    }

  ]

  tags = local.ghostcms_tags
}




module "db-private_route_table" {
  depends_on = [module.vpc, module.private-subnet-ap-south-1a, module.private-subnet-ap-south-1b, module.public-subnet-ap-south-1a, module.public-subnet-ap-south-1b, module.db-private-subnet-ap-south-1a, module.db-private-subnet-ap-south-1b]
  source     = "../modules/route-table"
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = var.vpc_cidr
  name       = "ghostcms-db-private-route-table"
  subnet_ids = [
    module.db-private-subnet-ap-south-1a.subnet_id,
    module.db-private-subnet-ap-south-1b.subnet_id

  ]

  routes = [
    {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = module.aws_nat_gateway.nat_gateway_id
    }

  ]

  tags = local.ghostcms_tags
}