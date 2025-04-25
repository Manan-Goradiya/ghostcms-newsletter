output "security_group_id" {
  description = "The ID of the Security Group"
  value = aws_security_group.security_group.id
}