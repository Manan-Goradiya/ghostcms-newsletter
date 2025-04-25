resource "aws_s3_bucket" "bucket" {
    tags = merge(
    var.tags,  # <-- Add common labels
    {
      Name = var.bucket_name
    }
  )
}
resource "aws_s3_bucket_versioning" "versioning" {
  depends_on = [ aws_s3_bucket.bucket ]
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}
resource "aws_s3_bucket_public_access_block" "public_access" {
  depends_on = [ aws_s3_bucket.bucket ]
  bucket = aws_s3_bucket.bucket.id
  block_public_acls   = var.block_public_access
  block_public_policy = var.block_public_access
  ignore_public_acls  = var.block_public_access
  restrict_public_buckets = var.block_public_access
}
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}