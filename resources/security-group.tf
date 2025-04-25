module "ghostcms-rds-security-group" {
  source      = "../modules/security-groups"
  depends_on = [ module.vpc ]
  description = "Allow DB connection on 3306 from private subnets of vpc"
  vpc_id      = module.vpc.vpc_id
  tags = local.ghostcms_tags
  security_group_name = "ghostcms-rds-security-group"
  rules = [
    # Ingress Rules (Allow SSH & RDP)
    {
      type        = "ingress"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [var.private_subnet_cidr_1, var.private_subnet_cidr_2]
    },
    # {
    #   type        = "ingress"
    #   from_port   = 3389
    #   to_port     = 3389
    #   protocol    = "tcp"
    #   cidr_blocks = ["0.0.0.0/0"]
    # },

    # Egress Rule (Allow All Outbound Traffic)
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
