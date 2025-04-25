output "internet_gateway_id" {
  description = "The ID of the NAT Gatwway "
  value = aws_internet_gateway.internet_gateway.id
}