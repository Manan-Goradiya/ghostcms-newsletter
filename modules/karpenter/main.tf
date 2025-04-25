terraform {
required_providers {
      kubectl = {
      source = "gavinbunney/kubectl"
    }
}
}

# Kapenter Controller
module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = var.role_name #"karpenter-controller-eks-bc-stag-${data.aws_region.current.name}"
  provider_url                  = var.provider_url #data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.karpenter_namespace}:karpenter"]
}


resource "aws_iam_role_policy" "karpenter_contoller" {
  name = var.karpenter_policy_name
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter",
          "eks:DescribeCluster",
          "ec2:DescribeImages",
          "pricing:GetProducts",
          "ec2:DescribeSpotPriceHistory"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node.arn
      }



    ]
  })


}


#Karpenter helm release
resource "helm_release" "karpenter" {
  namespace = var.karpenter_namespace

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.3.2"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = var.cluster_endpoint
  }
  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_node.name
  }

  set {
    name  = "webhooks.enabled"
    value = "false"
  }

  values = [
    <<-EOT
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: karpenter.sh/nodepool
                  operator: DoesNotExist
      podAntiAffinity: null
    EOT
  ]

}




# Worker node role
resource "aws_iam_role" "karpenter_node" {
  name = "karpenter-Workernode-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

## Instance profile for nodes to pull images, networking, SSM, etc
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "karpenter-node-${var.cluster_name}"
  role = aws_iam_role.karpenter_node.name
}


resource "aws_eks_access_entry" "karpenter_workernode_entry" {
  cluster_name      = var.cluster_name
  principal_arn     = aws_iam_role.karpenter_node.arn
  type              = "EC2_LINUX"
}



# Flowschema for karpenter-leader-election
resource "kubectl_manifest" "flowSchema_karpenter_leader_election" {
depends_on = [ helm_release.karpenter,aws_eks_access_entry.karpenter_workernode_entry,aws_iam_role.karpenter_node ]
yaml_body = <<YAML
apiVersion: flowcontrol.apiserver.k8s.io/v1
kind: FlowSchema
metadata:
  name: karpenter-leader-election
spec:
  distinguisherMethod:
    type: ByUser
  matchingPrecedence: 200
  priorityLevelConfiguration:
    name: leader-election
  rules:
  - resourceRules:
    - apiGroups:
      - coordination.k8s.io
      namespaces:
      - '*'
      resources:
      - leases
      verbs:
      - get
      - create
      - update
    subjects:
    - kind: ServiceAccount
      serviceAccount:
        name: karpenter
        namespace: "${var.karpenter_namespace}"
YAML

}

# Flowschema for karpenter-workload
resource "kubectl_manifest" "flowSchema_karpenter_workload" {
depends_on = [ kubectl_manifest.flowSchema_karpenter_leader_election,helm_release.karpenter,aws_eks_access_entry.karpenter_workernode_entry,aws_iam_role.karpenter_node ]
yaml_body = <<YAML
apiVersion: flowcontrol.apiserver.k8s.io/v1
kind: FlowSchema
metadata:
  name: karpenter-workload
spec:
  distinguisherMethod:
    type: ByUser
  matchingPrecedence: 1000
  priorityLevelConfiguration:
    name: workload-high
  rules:
  - nonResourceRules:
    - nonResourceURLs:
      - '*'
      verbs:
      - '*'
    resourceRules:
    - apiGroups:
      - '*'
      clusterScope: true
      namespaces:
      - '*'
      resources:
      - '*'
      verbs:
      - '*'
    subjects:
    - kind: ServiceAccount
      serviceAccount:
        name: karpenter
        namespace: "${var.karpenter_namespace}"
YAML

}