module "eks_cluster" {
  depends_on                 = [module.private-subnet-ap-south-1a, module.private-subnet-ap-south-1b, module.public-subnet-ap-south-1a, module.public-subnet-ap-south-1b, module.efs]
  source                     = "../modules/eks-cluster"
  vpc_id                     = module.vpc.vpc_id
  cluster_version            = "1.32"
  eks_cluster_name           = "ghostcms-eks"
  endpoint_private_access    = true
  endpoint_public_access     = true
  subnet_ids                 = [module.private-subnet-ap-south-1b.subnet_id, module.private-subnet-ap-south-1a.subnet_id]
  eks_node_group_name        = "ghostcms-node-group"
  instance_types             = ["t4g.medium"]
  default_nodegroup_ami_type = "AL2023_ARM_64_STANDARD"
  public_access_cidrs        = ["0.0.0.0/0"]

  max_size        = 1
  min_size        = 1
  desired_size    = 1
  disk_size       = 30
  max_unavailable = 1
  aws_region      = "ap-south-1"
  providers = {
    kubectl    = kubectl
    helm       = helm
    kubernetes = kubernetes
  }
  tags = local.ghostcms_tags
}