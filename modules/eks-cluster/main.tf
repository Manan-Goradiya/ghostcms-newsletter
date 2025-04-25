data "aws_caller_identity" "current" {}

resource "aws_eks_cluster" "eks_cluster" {
    vpc_config {
      subnet_ids = var.subnet_ids
      endpoint_private_access = var.endpoint_private_access
      endpoint_public_access  = var.endpoint_public_access
      public_access_cidrs = var.public_access_cidrs
    }
    name= var.eks_cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn
    version  = var.cluster_version
    tags = var.tags
    access_config {
      authentication_mode = "API_AND_CONFIG_MAP"
    }
}
resource "aws_iam_role" "eks_cluster_role"{
    name = "eks_cluster_role"
    assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}
resource "aws_iam_role" "node" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}
resource "aws_eks_node_group" "eks_node_group" {
  depends_on = [ aws_eks_cluster.eks_cluster ]
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_group_name
  node_role_arn = aws_iam_role.node.arn
  subnet_ids    = var.subnet_ids
  tags = var.tags
  instance_types = var.instance_types
  ami_type = var.default_nodegroup_ami_type
  scaling_config {
    desired_size =  var.desired_size
    max_size     =  var.max_size
    min_size     =  var.min_size
  }
  disk_size = var.disk_size
  update_config {
    max_unavailable = var.max_unavailable
  }
}
resource "aws_iam_role_policy_attachment" "eks_cluster_role_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}



resource "aws_eks_addon" "ebs_csi" {
  depends_on = [ aws_eks_cluster.eks_cluster,aws_eks_node_group.eks_node_group ]
  cluster_name                = var.eks_cluster_name #aws_eks_cluster.example.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.40.1-eksbuild.1" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn = aws_iam_role.ebs_csi.arn
  tags = var.tags
}

resource "aws_eks_addon" "metric_server" {
  depends_on = [ aws_eks_cluster.eks_cluster,aws_eks_node_group.eks_node_group ]
  cluster_name                = var.eks_cluster_name #aws_eks_cluster.example.name
  addon_name                  = "metrics-server"
  addon_version               = "v0.7.2-eksbuild.2" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  resolve_conflicts_on_update = "PRESERVE"
  tags = var.tags
}

# resource "helm_release" "secrets-store-csi-driver" {
#   depends_on = [ aws_eks_cluster.eks_cluster,aws_eks_node_group.eks_node_group ]
#   name       = "secrets-store-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = "secrets-store-csi-driver"
#   version    = "1.3.4"
#   namespace  = "kube-system"
#   timeout    = 10 * 60

#   values = [
#     <<VALUES
#     syncSecret:
#       enabled: true   # Install RBAC roles and bindings required for K8S Secrets syncing if true (default: false)
#     enableSecretRotation: true

#     ## Secret rotation poll interval duration
#     ##rotationPollInterval: 3600m
# VALUES
#   ]
# }


module "csi-secret-driver" {
  # depends_on = [ aws_eks_cluster.eks_cluster,aws_eks_node_group.eks_node_group,aws_eks_access_entry.sso_admin_access,aws_eks_access_policy_association.sso_admin_policy]
  source                             = "./csi-secret-driver"
  cluster_endpoint                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_certificate_authority_data = aws_eks_cluster.eks_cluster.certificate_authority.0.data
  eks_cluster_name                   = aws_eks_cluster.eks_cluster.name
  cluster_oidc_issuer_url            = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  oidc_provider_arn                  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}" #aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer #module.eks.oidc_provider_arn
  region = var.aws_region
  providers = {
    kubectl = kubectl
    helm    = helm
    kubernetes = kubernetes
  }
}




data "tls_certificate" "this" {
  # Not available on outposts
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}



resource "aws_iam_openid_connect_provider" "oidc_provider" {
    thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
    url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
    # arn             = "arn:aws:iam::013428324486:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/2A9EB8C7AC89927F7F77B3B13EDD50C5"
    client_id_list  = [
        "sts.amazonaws.com",
    ]
    # id              = "arn:aws:iam::013428324486:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/2A9EB8C7AC89927F7F77B3B13EDD50C5"
    tags            = {
    created_by    = "manan_g"
    maintained_by = "manan_g"
    owner         = "manan_g"
    sensitive     = "yes"
    environment   = "ghostcms"
    tenant        = "ghostcms"
  }
    tags_all        = {
    created_by    = "manan_g"
    maintained_by = "manan_g"
    owner         = "manana_g"
    sensitive     = "yes"
    environment   = "ghostcms"
    tenant        = "ghostcms"
  }

}

resource "kubernetes_namespace" "this" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
  }
}

# Fetch the current AWS region from your profile
data "aws_region" "current" {}

# Use the fetched region dynamically in IAM role path
# data "aws_iam_roles" "sso_roles" {
#   path_prefix = "/aws-reserved/sso.amazonaws.com/${data.aws_region.current.name}/"
# }
# locals {
#   sso_admin_role_arn = [for arn in data.aws_iam_roles.sso_roles.arns : arn
#     if can(regex("AWSReservedSSO_AdministratorAccess_", arn))
#   ][0] # Selects the first AdministratorAccess role dynamically
# }

# resource "aws_eks_access_entry" "sso_admin_access" {
#   depends_on = [ aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_node_group ]
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = local.sso_admin_role_arn
#   type          = "EC2"
# }

# resource "aws_eks_access_entry" "sso_admin_access" {
#   depends_on = [ aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_node_group ]
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = local.sso_admin_role_arn
#   type = "STANDARD"
#   tags = var.tags
# }
# resource "aws_eks_access_policy_association" "sso_admin_policy" {
#   depends_on = [ aws_eks_access_entry.sso_admin_access ]
#   cluster_name  = aws_eks_cluster.eks_cluster.name
#   principal_arn = local.sso_admin_role_arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#   access_scope {
#     type = "cluster"
#   }
# }

module "alb_controller" {
  # depends_on = [aws_eks_cluster.eks_cluster, aws_eks_node_group.eks_node_group , aws_eks_access_policy_association.sso_admin_policy ]
  source = "../alb-controller"
  cluster_name = var.eks_cluster_name
  vpc_id = var.vpc_id
  aws_region = var.aws_region
  tags = var.tags
  providers = {
    kubectl = kubectl
    helm    = helm
    kubernetes = kubernetes
  }
}

resource "kubernetes_storage_class" "gp3" {
  # depends_on = [aws_eks_addon.ebs_csi,aws_eks_access_entry.sso_admin_access]
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"  # Optional: makes this the default StorageClass
    }
  }

  storage_provisioner = "ebs.csi.aws.com"  # Use CSI driver instead of in-tree provisioner
  reclaim_policy      = "Retain"           # Options: Delete/Retain
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type       = "gp3"
    encrypted  = "true"
    "csi.storage.k8s.io/fstype"     = "ext4"
    # Optional gp3-specific parameters
    # iops       = "3000"        # Default is 3000
    # throughput = "125"         # Default is 125 MiB/s
  }
}
