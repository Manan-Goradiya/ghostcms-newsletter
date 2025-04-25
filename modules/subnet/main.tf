resource "aws_subnet" "sub-network" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet-cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = merge(
    var.tags, 
    {
      Name = var.subnet_name
    }
  )
}

