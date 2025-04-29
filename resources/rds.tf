module "trezix-dev-rds-instance" {
  depends_on                  = [module.db-private-subnet-ap-south-1a, module.db-private-subnet-ap-south-1b, module.private-subnet-ap-south-1b, module.ghostcms-rds-security-group]
  create_db_subnet_group      = true
  source                      = "../modules/rds"
  db_identifier               = "ghostcms-rds-instance"
  db_instance_class           = "db.t4g.small"
  db_engine                   = "mysql"
  db_engine_version           = "8.0"
  db_subnet_group_name        = "ghostcms-rds-subnet-group"
  vpc_security_group_ids      = [module.ghostcms-rds-security-group.security_group_id]
  allocated_storage           = 30
  max_allocated_storage       = 30
  tags                        = local.ghostcms_tags
  db_availability_zone        = "ap-south-1a"
  subnet_ids                  = [module.db-private-subnet-ap-south-1a.subnet_id, module.db-private-subnet-ap-south-1b.subnet_id]
  db_instance_master_username = "root"
  deletion_protection         = true
}
