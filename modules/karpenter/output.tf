output "instance_profile" {
  value = aws_iam_instance_profile.karpenter_node.name
}