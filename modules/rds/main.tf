
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%$#*"
}
resource "aws_db_instance" "rds" {
  depends_on = [ aws_db_subnet_group.db_subnet_group,random_password.db_password ]
  identifier              = var.db_identifier
  username                = var.db_instance_master_username
  storage_type              = "gp3"
  password               =  random_password.db_password.result
  instance_class          = var.db_instance_class
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = var.vpc_security_group_ids
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.db_identifier}-final-snapshot"
  deletion_protection = var.deletion_protection
  tags = var.tags
  availability_zone = var.db_availability_zone
    lifecycle {
    ignore_changes = [password]
  }
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids
  tags = merge(
    var.tags,
    {
      Name ="db-subnet-group"
    }
  )
}