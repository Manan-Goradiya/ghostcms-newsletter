resource "helm_release" "secrets-store-csi-driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.3.4"
  namespace  = "kube-system"
  timeout    = 10 * 60

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }


  values = [
    <<VALUES
    syncSecret:
      enabled: true   # Install RBAC roles and bindings required for K8S Secrets syncing if true (default: false)
    enableSecretRotation: true

    ## Secret rotation poll interval duration
    ##rotationPollInterval: 3600m
VALUES
  ]
}


locals {
  csi_secret_driver_yaml = file("${path.module}/csi-secret-driver.yaml")
  yaml_documents = [for doc in split("---", local.csi_secret_driver_yaml) : doc if trimspace(doc) != ""]
  manifests = { for idx, doc in local.yaml_documents : idx => doc if trimspace(doc) != "" }
}

resource "kubectl_manifest" "csi-secrets-store" {
  for_each  = local.manifests
  yaml_body = each.value
}



# Trusted entities
data "aws_iam_policy_document" "secrets_csi_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:*:secrets-csi-policy-sa"]
    }
    #module.eks.cluster_oidc_issuer_url
    condition {
      test     = "StringLike"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.oidc_provider_arn]
      type        = "Federated"
    }
  }
}
#module.eks.oidc_provider_arn
# Role
resource "aws_iam_role" "secrets_csi" {
  assume_role_policy = data.aws_iam_policy_document.secrets_csi_assume_role_policy.json
  name               = "dev-stag-${var.region}-secrets-csi-role"
}

# Policy
resource "aws_iam_policy" "secrets_csi" {

  name = "dev-stag-${var.region}-secrets-csi-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = ["*"]
    }]
  })
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "secrets_csi" {

  policy_arn = aws_iam_policy.secrets_csi.arn
  role       = aws_iam_role.secrets_csi.name
}

# Service Account
resource "kubectl_manifest" "secrets_csi_sa" {

  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: secrets-csi-policy-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.secrets_csi.arn}
YAML

}