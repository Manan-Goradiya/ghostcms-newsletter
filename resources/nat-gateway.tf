module "aws_nat_gateway" {
  depends_on = [ module.vpc,module.public-subnet-ap-south-1a, module.public-subnet-ap-south-1b] 
  source = "../modules/nat-gateway" 
  subnet_id = module.public-subnet-ap-south-1a.subnet_id #need to provide array
  name = var.nat_gateway_name
  tags = local.ghostcms_tags
}