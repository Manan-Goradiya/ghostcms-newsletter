
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id
  tags = merge(
    var.tags,
    {
      Name = var.igw_name
    }
  )
}