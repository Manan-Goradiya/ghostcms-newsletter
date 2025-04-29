module "efs" {
  source                = "../modules/efs"
  security_group_vpc_id = module.vpc.vpc_id
  efs_name              = "ghostcms-efs"
  vpc_cidr              = var.vpc_cidr
  private_subnet_1_id   = module.private-subnet-ap-south-1a.subnet_id
  private_subnet_2_id   = module.private-subnet-ap-south-1b.subnet_id
}