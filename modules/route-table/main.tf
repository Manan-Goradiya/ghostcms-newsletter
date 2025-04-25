# Create Route Table
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.vpc_cidr  # The CIDR of the VPC itself (e.g., "10.0.0.0/16")
    gateway_id = "local"             # Mandatory for VPC-local routing
  }

  dynamic "route" {
    for_each = var.routes
    content {
      cidr_block     = route.value.cidr_block
      gateway_id                = contains(keys(route.value), "gateway_id") ? route.value.gateway_id : null
    nat_gateway_id            = contains(keys(route.value), "nat_gateway_id") ? route.value.nat_gateway_id : null
    vpc_peering_connection_id = contains(keys(route.value), "vpc_peering_connection_id") ? route.value.vpc_peering_connection_id : null
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "this" {
  depends_on = [ aws_route_table.route_table ]
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.route_table.id
}
