resource "aws_iam_role" "custom_role" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  tags = var.tags
}
resource "aws_iam_policy" "custom_policies" {
  for_each = var.custom_policies
  name   = "${var.role_name}-${each.key}"
  policy = each.value
  tags = var.tags
}
resource "aws_iam_policy_attachment" "managed_policies" {
  for_each   = toset(var.managed_policy_arns)
  name       = "${var.role_name}-attachment-${each.key}"
  policy_arn = each.value
  roles      = [aws_iam_role.custom_role.name]
}