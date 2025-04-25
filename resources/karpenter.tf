module "karpenter" {
  source = "../modules/karpenter"
  depends_on = [ module.eks_cluster ]
  cluster_name = var.eks_cluster_name
  cluster_endpoint = module.eks_cluster.cluster_endpoint #data.aws_eks_cluster.eks.endpoint
  role_name = "ghostcms-karpenter-controller-role"
  provider_url = module.eks_cluster.cluster_provider_url #data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  karpenter_namespace = "karpenter"
  karpenter_policy_name = "ghostcms-karpenter-controller-policy"

  providers = {
    kubectl = kubectl
    helm = helm
    kubernetes = kubernetes
  }

}



locals {
  # Get YAML filenames (not full paths)
  provisioner_files = fileset("${path.module}/provisioner", "*.yaml")

  # Build a stable mapping structure that doesn't depend on variable interpolation
  provisioner_mapping = flatten([
    for file in local.provisioner_files : [
      for i, doc in [
        for doc in split("---", file("${path.module}/provisioner/${file}")) :
        trimspace(doc) if trimspace(doc) != ""
      ] : {
        key = "${file}-${i}"  # Stable key based on filename and document index
        file = file
        index = i
      }
    ]
  ])
}

# Create the resources using the stable mapping
resource "kubectl_manifest" "provisioners" {
  depends_on = [ module.eks_cluster,module.karpenter ]
  for_each = {
    for item in local.provisioner_mapping : item.key => item
  }

  # Get the specific YAML document with variables substituted
  yaml_body = element(
    [
      for doc in split("---", templatefile(
        "${path.module}/provisioner/${each.value.file}",
        {
          cluster_name     = var.eks_cluster_name
          INSTANCE_PROFILE = module.karpenter.instance_profile
          EKS_NODE_SG      = module.eks_cluster.cluster_security_group_id
        }
      )) : trimspace(doc) if trimspace(doc) != ""
    ],
    each.value.index
  )
}
