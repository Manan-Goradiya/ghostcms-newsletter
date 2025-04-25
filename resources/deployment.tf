# provider "kubernetes" {
#   config_path = "~/.kube/config"  # Update for EKS auth
# }


# Deploy Ghost CMS
resource "kubernetes_deployment" "ghost" {
  metadata {
    name = "ghost"
    namespace = "ghostcms" # Replace with your namespace if needed
    labels = {
      app = "ghost"
    }
  }
  spec {
    replicas = 0
    selector {
      match_labels = {
        app = "ghost"
      }
    }
    template {
      metadata {
        labels = {
          app = "ghost"
        }
      }
      spec {
        container {
          name  = "ghost"
          image = "ghost:latest"
          port {
            container_port = 2368
          }
          env {
            name  = "url"
            value = "http://k8s-ghostcms-ghostalb-a1eecbcb0e-1838722857.ap-south-1.elb.amazonaws.com"
          }
          env {
            name  = "NODE_ENV"
            value = "production"
          }


          env {
            name  = "database__client"
            value = "mysql"
          }

          env {
            name  = "database__connection__host"
            value = "ghostcms-rds-instance.cdwcm0eimt9l.ap-south-1.rds.amazonaws.com"
          }          
          env {
            name  = "database__connection__user"
            value = "root"
          }
          env {
            name  = "database__connection__password"
            value = "[)-X|63F<gE<moj~(-QbSz>y(E3O"
          }
          env {
            name  = "database__connection__database"
            value = "ghost"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
        security_context {
          fs_group = 1000
        }
      }
    }
  }
}
resource "kubernetes_horizontal_pod_autoscaler_v2" "ghost_hpa" {
  metadata {
    name      = "ghost-hpa"
    namespace = "ghostcms" # Replace with your namespace if needed
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.ghost.metadata[0].name
    }

    min_replicas = 1  # Minimum replicas (ensures availability)
    max_replicas = 5  # Maximum replicas under load

    # CPU-based scaling
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70  # Scale up if CPU >70%
        }
      }
    }

    # Memory-based scaling
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 70  # Scale up if Memory >70%
        }
      }
    }

    # (Optional) Behavior configurations
    behavior {
      scale_down {
        stabilization_window_seconds = 300  # Wait 5 minutes before scaling down
        select_policy                = "Min"
        policy {
          type          = "Pods"
          value        = 1
          period_seconds = 60  # Remove 1 pod per minute when scaling down
        }
      }
      scale_up {
        stabilization_window_seconds = 60  # Wait 1 minute before scaling up
        select_policy                = "Max"
        policy {
          type          = "Pods"
          value        = 2  # Add 2 pods at a time when scaling up
          period_seconds = 15  # Every 15 seconds if thresholds are still breached
        }
      }
    }
  }
}
# PDB for Ghost
resource "kubernetes_pod_disruption_budget_v1" "ghost_pdb" {
  metadata {
    name = "ghost-pdb"
  }
  spec {
    min_available = "1"
    selector {
      match_labels = {
        app = kubernetes_deployment.ghost.metadata[0].labels.app
      }
    }
  }
}

# (Optional) Service and Ingress for external access
resource "kubernetes_service" "ghost" {
  metadata {
    name = "ghost"
    namespace = "ghostcms"  # Replace with your namespace if needed
  }
  spec {
    selector = {
      app = kubernetes_deployment.ghost.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 2368
    }
    type = "ClusterIP"  # Use "ClusterIP" if behind Ingress
  }
}