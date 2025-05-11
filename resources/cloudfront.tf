module "cloudfront" {
  source                 = "../modules/cloudfront"
  load_balancer_hostname = kubernetes_ingress_v1.ghost_alb_ingress.status.0.load_balancer.0.ingress.0.hostname
  aliases                = ["manandevops.site"]
  alb_origin             = "ghost.manandevops.site"
  s3_origin              = "ghostcmss3.s3.amazonaws.com"
}