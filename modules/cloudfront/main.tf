module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

#   aliases = ["cdn.example.com"]

  comment             = "GhostCMS CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    GhostCMS_S3 = "OAI for GhostCMS S3 bucket"
  }

#   logging_config = {
#     bucket = "logs-my-cdn.s3.amazonaws.com"
#   }

   origin = {
#     GhostCMS_S3 = {
#       domain_name = "ghostcmss3.s3.amazonaws.com"
#     #   custom_origin_config = {
#     #     http_port              = 80
#     #     https_port             = 443
#     #     origin_protocol_policy = "match-viewer"
#     #     origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#     #   }
#     }

    GhostCMS_S3 = {
      domain_name = "ghostcmss3.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "GhostCMS_S3"
      }
    }
   }

  default_cache_behavior = {
    target_origin_id           = "GhostCMS_S3"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/ghost/*"
      target_origin_id       = "GhostCMS_S3"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

#   viewer_certificate = {
#     acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
#     ssl_support_method  = "sni-only"
#   }
}