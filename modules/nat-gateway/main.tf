
resource "aws_nat_gateway" "nat"{
    depends_on = [aws_eip.nat]
    subnet_id = var.subnet_id
    allocation_id = aws_eip.nat.id
    # allocation_id = data.aws_eip.nat.id
    tags = merge(
    var.tags, 
    {
      Name = var.name
    }
  )
#  lifecycle {
   
#  }
}
# remove it , patching it with data block
resource "aws_eip" "nat" {
 domain = "vpc"
 tags = merge(
    var.tags, 
    {
      Name ="${var.name}-eip"
  } 
  )
}
# data "aws_eip" "nat" {    use this production ad apply lifecyle for creating it every apply 
#   id = var.alloaction_id
# }
