output "nat_gateway_id" {
  description = "The ID of the NAT Gatwway "
  value = aws_nat_gateway.nat.id
}