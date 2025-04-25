module "eks_cluster" {
    depends_on = [ module.private-subnet-ap-south-1a, module.private-subnet-ap-south-1b,module.public-subnet-ap-south-1a,module.public-subnet-ap-south-1b ]

    source = "../modules/eks-cluster"
    # vpc_name        = "ghostcms-vpc"
    vpc_id = module.vpc.vpc_id
cluster_version="1.32"
eks_cluster_name = "ghostcms-eks"
# vpc_cidr = "172.25.0.0/16"
  endpoint_private_access = true
  endpoint_public_access = true
subnet_ids = [ module.private-subnet-ap-south-1b.subnet_id, module.private-subnet-ap-south-1a.subnet_id]
# private_subnet_cidr_1="172.25.128.0/20"
# private_subnet_cidr_2="172.25.144.0/20"
# public_subnet_cidr_1="172.25.0.0/20"
# public_subnet_cidr_2="172.25.16.0/20"
# nat_gateway_name="ghostcms-nat-gateway"
eks_node_group_name="ghostcms-node-group"
instance_types=["t4g.medium"]
default_nodegroup_ami_type="AL2023_ARM_64_STANDARD"
public_access_cidrs = ["0.0.0.0/0"]

  max_size = 1
  min_size = 1
  desired_size = 1
  disk_size = 30
  max_unavailable = 1
  aws_region = "ap-south-1"
  providers = {
    kubectl = kubectl
    helm = helm
    kubernetes = kubernetes
  }



# karpenter_namespace="karpenter"

# karpenter_controller_role_name   = "ghostcms-karpenter-controller-role"
# karpenter_controller_policy_name = "ghostcms-karpenter-controller-policy"
tags = local.ghostcms_tags
# ghostcms_tags   = {
#     created_by    = "manan_g"
#     environment   = "monitoring"
#     maintained_by = "manan_g"
#     owner         = "trezix"
#     sensitive     = "no"
#     tenant        = "monitoring"
#   }
  # vpc_name        = "tz-monitoring-vpc"
}