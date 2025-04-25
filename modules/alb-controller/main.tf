# Install ALB Controller Using Helm
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

data "tls_certificate" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
resource "aws_iam_role" "alb_controller" {
  name = "alb-controller-role"
  tags = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks_oidc.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}
resource "kubernetes_service_account" "alb_controller" {
  
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }

}
resource "helm_release" "alb_controller" {
  depends_on = [ kubernetes_service_account.alb_controller ]
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }
}
resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  depends_on = [ aws_iam_role.alb_controller,aws_iam_policy.alb_controller_custom ]
  policy_arn = aws_iam_policy.alb_controller_custom.arn
  role       = aws_iam_role.alb_controller.name
}

resource "aws_iam_policy" "alb_controller_custom" {
  name        = "AWSLoadBalancerControllerCustom"
  description = "Custom policy for ALB Controller"
  policy = file("${path.module}/policy.json")
}
