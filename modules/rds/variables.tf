variable "db_identifier" {
  description = "The name of the RDS instance"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
}


variable "vpc_security_group_ids" {
  description = "A list of VPC security groups to associate with the RDS instance"
  type        = list(string)
}

variable "allocated_storage" {
  description = "The allocated storage size in GB"
  type        = number
}

variable "max_allocated_storage" {
  description = "The maximum allocated storage size in GB"
  type        = number
}
variable "subnet_ids" {
  type = list(string)
  description = "List of subnet id for rds instance"
}
variable "tags" {
  type        = map(string)
  description = "Tags to be added to the resource"
}
variable "db_availability_zone" {
  type = string
  description = "Availability Zone of the DB instance"
}
variable "db_instance_master_username" {
  type = string
  description = "Username for db instance"
}

variable "skip_final_snapshot" {
  type = bool
  description = "whether a final DB snapshot is created before the DB instance is deleted true/false"
  default = false
}

variable "create_db_subnet_group" {
  type        = bool
  description = "Whether to create a DB subnet group"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of the DB subnet group"
}

variable "deletion_protection" {
  type = string
  description = "if set to true, the database can't be deleted"
}