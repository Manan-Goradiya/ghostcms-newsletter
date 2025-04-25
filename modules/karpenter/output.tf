# output "karpenter_worker_node" {
#   value = aws_iam_instance_profile.karpenter_node.arn
# }


output "instance_profile" {
  value = aws_iam_instance_profile.karpenter_node.name
}