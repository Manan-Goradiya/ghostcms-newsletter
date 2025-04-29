locals {
    mount_target = {
    "ap-south-1a" = {
      subnet_id = var.private_subnet_1_id
    }
    "ap-south-1b" = {
      subnet_id = var.private_subnet_2_id
    }
    }
    
}


module "efs" {

  source           = "terraform-aws-modules/efs/aws"
  name             = var.efs_name
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  mount_targets = local.mount_target

  security_group_description = "Security group for EFS"
  security_group_vpc_id      = var.security_group_vpc_id
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC public subnets"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  # Backup policy
  enable_backup_policy = true
  tags = var.ghostcms_tags


}


resource "aws_efs_access_point" "eks_app_access_point" {
    depends_on = [module.efs]
  file_system_id = module.efs.id 
  posix_user {
    gid = 1000
    uid = 1000
  }
  
  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
  
  tags = var.ghostcms_tags
}