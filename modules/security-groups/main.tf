resource "aws_security_group" "security_group" {
    name = var.security_group_name
    description = var.description
    vpc_id = var.vpc_id
    tags = var.tags
}
resource "aws_security_group_rule" "rules" {
  for_each = { for rule in var.rules : "${rule.type}-${rule.from_port}-${rule.to_port}" => rule }
  type              = each.value.type  # Can be "ingress" or "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.security_group.id
  cidr_blocks              = lookup(each.value, "cidr_blocks", [])
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}
