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
  cluster_name                = var.eks_cluster_name 
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.40.1-eksbuild.1" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn = aws_iam_role.ebs_csi.arn
  tags = var.tags
}

resource "aws_eks_addon" "metric_server" {
  depends_on = [ aws_eks_cluster.eks_cluster,aws_eks_node_group.eks_node_group ]
  cluster_name                = var.eks_cluster_name
  addon_name                  = "metrics-server"
  addon_version               = "v0.7.2-eksbuild.2" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
  resolve_conflicts_on_update = "PRESERVE"
  tags = var.tags
}


module "csi-secret-driver" {
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
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}



resource "aws_iam_openid_connect_provider" "oidc_provider" {
    thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
    url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
    client_id_list  = [
        "sts.amazonaws.com",
    ]
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

module "alb_controller" {
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
  }
}
