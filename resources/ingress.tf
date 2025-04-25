resource "kubernetes_ingress_v1" "ghost_alb_ingress" {
  metadata {
    name      = "ghost-alb-ingress"
    namespace = "ghostcms"  # Update if Ghost is in another namespace
    annotations = {
      # ALB-specific annotations
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"     = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{ "HTTP" = 80 } /*, { "HTTPS" = 443 } */])
    #   "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate.ghost_cert.arn  # Required for HTTPS
      # "alb.ingress.kubernetes.io/ssl-redirect" = "443"  # Redirect HTTP → HTTPS
    }
  }

  spec {
    rule {
      host = "k8s-ghostcms-ghostalb-a1eecbcb0e-1838722857.ap-south-1.elb.amazonaws.com"  # Replace with your domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.ghost.metadata[0].name  #kubernetes_service.ghost.metadata[0].name  # Reference your Ghost Service
              port {
                number = 80  # Matches the service port
              }
            }
          }
        }
      }
    }
  }

}