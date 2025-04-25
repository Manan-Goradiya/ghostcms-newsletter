
resource "kubernetes_manifest" "tz-dev-stag-redis-cluster" {
  provider = kubernetes
  depends_on = [helm_release.tz-dev-stag-redis-operator]
  manifest = {
    apiVersion = "databases.spotahome.com/v1"
    kind       = "RedisFailover"
    metadata = {
      name      = "tz-${var.environment}-redis-cluster"
      namespace = var.environment #helm_release.tz-jsw-prod-redis-operator.namespace
      # labels    = local.tz_jsw_prod_labels
    }
    spec = {
      redis = {
        replicas = 2
        affinity = {
          nodeAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 1
              preference = {
                matchExpressions = [{
                  key      = "app.stateful/component"
                  operator = "In"
                  values   = ["redis"]
                }]
              }
            }]
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "intent"
                  operator = "In"
                  values   = ["redis"]
                }]
              }]
            }
          }
        }
        # tolerations = [{
        #   key      = "app.stateful/component"
        #   operator = "Equal"
        #   value    = "${var.environment}-redis-operator"
        #   effect   = "NoSchedule"
        # }]
        topologySpreadConstraints = [{
          maxSkew           = 1
          topologyKey       = "topology.kubernetes.io/zone"
          whenUnsatisfiable = "DoNotSchedule"
          labelSelector = {
            matchLabels = {
              "redisfailovers.databases.spotahome.com/name" = "tz-${var.environment}-redis-cluster"
              "app.kubernetes.io/component"                 = "redis"
            }
          }
        }]
        podAnnotations = {
        #   "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true"
          "sidecar.istio.io/inject"                        = "false"
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "512Mi"
          }
        }
        storage = {
          persistentVolumeClaim = {
            metadata = {
              name = "${var.environment}-redis-cluster-data"
            }
            spec = {
              accessModes = ["ReadWriteOnce"]
              resources = {
                requests = {
                  storage = "5Gi"
                }
              }
              storageClassName = "gp3"
            }
          }
        }
        exporter = {
          enabled = "true"
          image   = "oliver006/redis_exporter:v1.43.1"
          args    = ["--include-system-metrics", "--web.telemetry-path", "/metrics"]
          env = [{
            name  = "REDIS_EXPORTER_LOG_FORMAT"
            value = "txt"
          }]
        }
      }
      sentinel = {
        replicas = 2
        customConfig = [
          "down-after-milliseconds 1000",
          "failover-timeout 1000"
        ]
        affinity = {
          nodeAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 1
              preference = {
                matchExpressions = [{
                  key      = "intent"
                  operator = "In"
                  values   = ["redis"]
                }]
              }
            }]
            # requiredDuringSchedulingIgnoredDuringExecution = {
            #   nodeSelectorTerms = [{
            #     matchExpressions = [{
            #       key      = "cloud.google.com/machine-family"
            #       operator = "In"
            #       values   = ["n2d"]
            #     }]
            #   }]
            # }
          }
        }
        # tolerations = [{
        #   key      = "app.stateful/component"
        #   operator = "Equal"
        #   value    = "${var.environment}-redis-operator"
        #   effect   = "NoSchedule"
        # }]
        topologySpreadConstraints = [{
          maxSkew           = 1
          topologyKey       = "topology.kubernetes.io/zone"
          whenUnsatisfiable = "DoNotSchedule"
          labelSelector = {
            matchLabels = {
              "redisfailovers.databases.spotahome.com/name" = "tz-${var.environment}-redis-cluster"
              "app.kubernetes.io/component"                 = "sentinel"
            }
          }
        }]
        podAnnotations = {
        #   "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true"
          "sidecar.istio.io/inject"                        = "false"
        }
        resources = {
          requests = {
            cpu    = "100m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "512Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "tz-dev-stag-redis-cluster" {
  depends_on = [helm_release.tz-dev-stag-redis-operator]
  metadata {
    name      = "tz-${var.environment}-redis-cluster"
    namespace = var.environment #helm_release.tz-jsw-prod-redis-operator.namespace
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "redis"
      port        = 6379
      protocol    = "TCP"
      target_port = 6379
    }
    selector = {
      "app.kubernetes.io/component" = "redis"
      "app.kubernetes.io/name"      = "tz-${var.environment}-redis-cluster"
      "redisfailovers-role"         = "master"
    }
  }
}
