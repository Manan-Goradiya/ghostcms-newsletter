data "aws_iam_policy_document" "ebs_csi_irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [ "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
                
      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_irsa.json
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}