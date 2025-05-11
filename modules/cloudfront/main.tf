module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

   aliases = var.aliases

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

    loadbalancer = {
      domain_name = var.alb_origin #var.load_balancer_hostname #module.eks_cluster.cluster_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }

    GhostCMS_S3 = {
      domain_name = var.s3_origin #"ghostcmss3.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "GhostCMS_S3"
      }
    }
   }

  default_cache_behavior = {
    target_origin_id           = "loadbalancer"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
    use_forwarded_values = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized    
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/ghostimages/*"
      target_origin_id       = "GhostCMS_S3"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    },


    {
      path_pattern           = "/*.js"
      target_origin_id       = "loadbalancer"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
      use_forwarded_values = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    },


    {
      path_pattern           = "/*.css"
      target_origin_id       = "loadbalancer"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
      use_forwarded_values = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    },

    
    {
      path_pattern           = "/*.woff2"
      target_origin_id       = "loadbalancer"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
      use_forwarded_values = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    },

    {
      path_pattern           = "/ghost/api/content/*"
      target_origin_id       = "loadbalancer"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
      use_forwarded_values = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    },


    {
      path_pattern           = "/ghost/api/admin/*"
      target_origin_id       = "loadbalancer"
      viewer_protocol_policy = "allow-all" #"redirect-to-https"

      allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      # cached_methods  = [""]
      compress        = true
      query_string    = true
      use_forwarded_values = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      cache_policy_id  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" 
    }    


  ]

  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:165551903801:certificate/c0a86c4d-d6e2-4f99-a496-ca5cc9cb9148"
    ssl_support_method  = "sni-only"
  }
}