provider "aws" {
  region  = "ap-south-1"
  profile = "manan-devops"
}

resource "kubernetes_storage_class_v1" "ghostcms_efs_sc" {
  metadata {
    name = "ghostcms-efs-sc" # Replace with your desired name
  }
  storage_provisioner = "efs.csi.aws.com"
  mount_options = [
    "rsize=1048576",
    "wsize=1048576",
    "hard",
    "timeo=600",
    "retrans=2"
  ]
  parameters = {
    "directoryPerms"        = "700"
    "fileSystemId"          = module.efs.efs_file_system_id #aws_efs_file_system.eks_efs.id
    "provisioningMode"      = "efs-ap"
    "uid"                   = "0"
    "gid"                   = "0"
    "subPathPattern"        = "/content"
    "ensureUniqueDirectory" = "false"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}





resource "kubernetes_storage_class_v1" "ghostcms_efs_sc_2" {
  metadata {
    name = "ghostcms-efs-sc-2" # Replace with your desired name
  }
  storage_provisioner = "efs.csi.aws.com"
  mount_options = [
    "rsize=1048576",
    "wsize=1048576",
    "hard",
    "timeo=600",
    "retrans=2"
  ]
  parameters = {
    "directoryPerms"        = "700"
    "fileSystemId"          = module.efs.efs_file_system_id #aws_efs_file_system.eks_efs.id
    "provisioningMode"      = "efs-ap"
    "uid"                   = "0"
    "gid"                   = "0"
    "subPathPattern"        = "/versions"
    "ensureUniqueDirectory" = "false"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}






# storageclass-ebs.tf
resource "kubernetes_storage_class" "ebs_standard" {
  metadata {
    name = "ghostcms-ebs-standard"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true" # Make it default
    }
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain" # Or "Delete" for auto-cleanup
  volume_binding_mode = "Immediate"

  parameters = {
    type      = "gp3"  # Allowed: gp2, gp3, io1, io2, sc1, st1
    fsType    = "ext4" # File system type
    encrypted = "true" # Enable EBS encryption
    # iopsPerGB = "50"  # Only for io1/io2 types
    # throughput = "250"  # Only for gp3 (MiB/s)
  }

  # For production clusters, add these:
  allow_volume_expansion = true
  mount_options          = ["debug"] # Optional mount flags
}










resource "kubernetes_persistent_volume_claim_v1" "ghostcms_efs_pvc" {
  metadata {
    name      = "ghostcms-efs-pvc" # Replace with your desired name
    namespace = "ghostcms"         # Replace with your namespace if needed
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
    storage_class_name = kubernetes_storage_class_v1.ghostcms_efs_sc.metadata[0].name
  }
}


resource "kubernetes_persistent_volume_claim_v1" "ghostcms_efs_pvc_2" {
  metadata {
    name      = "ghostcms-efs-pvc-2" # Replace with your desired name
    namespace = "ghostcms"           # Replace with your namespace if needed
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
    storage_class_name = kubernetes_storage_class_v1.ghostcms_efs_sc_2.metadata[0].name
  }
}




# resource "kubernetes_persistent_volume_claim_v1" "ghostcms_ebs_pvc" {
#   metadata {
#     name      = "ghostcms-ebs-pvc" # Replace with your desired name
#     namespace = "ghostcms"         # Replace with your namespace if needed
#   }
#   spec {
#     access_modes = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         "storage" = "18Gi"
#       }
#     }
#     storage_class_name = kubernetes_storage_class.ebs_standard.metadata[0].name
#   }
# }




# resource "kubernetes_config_map" "ghostcms_config" {
#   metadata {
#     name      = "ghostcms-config"
#     namespace = "ghostcms" # Replace with your namespace if needed
#   }

#   data = {
#     "config.production.json" = "${file("${path.module}/config.production.json")}"
#   }

#   # binary_data = {
#   #   "my_payload.bin" = "${filebase64("${path.module}/my_payload.bin")}"
#   # }
# }









# Deploy Ghost CMS
resource "kubernetes_deployment" "ghost" {
  depends_on = [kubernetes_persistent_volume_claim_v1.ghostcms_efs_pvc, kubernetes_storage_class_v1.ghostcms_efs_sc, kubernetes_manifest.ghostcms_secret_provider_class, /*kubernetes_config_map.ghostcms_config*/]
  metadata {
    name      = "ghost"
    namespace = "ghostcms" # Replace with your namespace if needed
    labels = {
      app = "ghost"
    }
  }
  spec {
    replicas = 2
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

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "intent"
                  operator = "In"
                  values   = ["ghostcms-stag"]
                }
              }
            }
          }
        }

        volume {
          name = "ghostcms-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.ghostcms_efs_pvc.metadata[0].name
          }
        }

        # volume {
        #   name = "ghostcms-vol-2"
        #   persistent_volume_claim {
        #     claim_name = kubernetes_persistent_volume_claim_v1.ghostcms_efs_pvc_2.metadata[0].name
        #   }
        # }

        # volume {
        #   name = "ghostcms-vol"
        #   persistent_volume_claim {
        #     claim_name = kubernetes_persistent_volume_claim_v1.ghostcms_ebs_pvc.metadata[0].name
        #   }
        # }


        volume {
          name = "ghostcms-secret"
          csi {
            driver    = "secrets-store.csi.k8s.io"
            read_only = true
            volume_attributes = {
              secretProviderClass = "spc-ghostcms"
            }
          }
        }
        # volume {
        #   name = "ghost-configmap"
        #   config_map {
        #     name = kubernetes_config_map.ghostcms_config.metadata[0].name
        #     items {
        #       key  = "config.production.json"
        #       path = "config.production.json" # Specify the file name if needed
        #     }
        #   }
        # }

        service_account_name = "ghostcms-sa"
        container {
          name = "ghost"
          # image = "ghost:latest"
          image = "165551903801.dkr.ecr.ap-south-1.amazonaws.com/ghostcms:latest-27"
          port {
            container_port = 2368
          }
          # env {
          #   name  = "url"
          #   value = "http://k8s-ghostcms-ghostalb-a1eecbcb0e-1838722857.ap-south-1.elb.amazonaws.com"
          # }
          env {
            name  = "NODE_ENV"
            value = "production"
          }


          env {
            name  = "database__client"
            value = "mysql"
          }
          env {
            name  = "AWS_DEFAULT_REGION"
            value = "ap-south-1"
          }
          env {
            name  = "AWS_REGION"
            value = "ap-south-1"
          }
          env {
            name  = "GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET" //the description regarding this variable is given wrongly in the documentation
            value = "ghostcmss3"
          }
          env {
            name = "database__connection__host"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "database__connection__host"
              }
            }
          }
          env {
            name = "database__connection__user"

            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "database__connection__user"
              }
            }
          }
          env {
            name = "database__connection__password"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "database__connection__password"
              }
            }
          }
          env {
            name = "database__connection__database"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "database__connection__database"
              }
            }
          }
          env {
            name = "url"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "url"
              }
            }
          }
          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "accessKeyId"
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "secretAccessKey"
              }
            }
          }

          env {
            name = "GHOST_STORAGE_ADAPTER_S3_ASSET_HOST"
            value_from {
              secret_key_ref {
                name = "secret-ghostcms"
                key  = "GHOST_STORAGE_ADAPTER_S3_ASSET_HOST"
              }
            }
          }


          resources {
            requests = {
              cpu    = "100m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "500m"
              memory = "1500Mi"
            }
          }
          volume_mount {
            mount_path = "/secrets"
            name       = "ghostcms-secret"
          }

          volume_mount {
            name       = "ghostcms-vol"
            mount_path = "/var/lib/ghost/content"
            # mount_path = "/"
          }

          # volume_mount {
          #   name       = "ghostcms-vol"
          #   mount_path = "/var/lib/ghost/content"
          # } 
          # volume_mount {
          #   name       = "ghostcms-vol-2"
          #   mount_path = "/var/lib/ghost/versions"
          # }                    

          # volume_mount {
          #   name       = "ghost-configmap"
          #   mount_path = "/var/lib/ghost/config.production.json"
          #   sub_path   = "config.production.json" # Specify the file name if needed
          # }

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

    min_replicas = 1 # Minimum replicas (ensures availability)
    max_replicas = 5 # Maximum replicas under load

    # CPU-based scaling
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70 # Scale up if CPU >70%
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
          average_utilization = 70 # Scale up if Memory >70%
        }
      }
    }

    # (Optional) Behavior configurations
    behavior {
      scale_down {
        stabilization_window_seconds = 300 # Wait 5 minutes before scaling down
        select_policy                = "Min"
        policy {
          type           = "Pods"
          value          = 1
          period_seconds = 60 # Remove 1 pod per minute when scaling down
        }
      }
      scale_up {
        stabilization_window_seconds = 60 # Wait 1 minute before scaling up
        select_policy                = "Max"
        policy {
          type           = "Pods"
          value          = 2  # Add 2 pods at a time when scaling up
          period_seconds = 15 # Every 15 seconds if thresholds are still breached
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
    name      = "ghost"
    namespace = "ghostcms" # Replace with your namespace if needed
  }
  spec {
    selector = {
      app = kubernetes_deployment.ghost.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 2368
    }
    type = "ClusterIP" # Use "ClusterIP" if behind Ingress
  }
}



resource "kubernetes_manifest" "ghostcms_service_account" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "ghostcms-sa"
      namespace = "ghostcms"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.ghostcms_iam_role.arn
      }
    }
  }
}


data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "ghostcms_iam_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks_cluster.cluster_provider_url, "https://", "")}"] #[ "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks_cluster.oidc_provider_arn})}"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(module.eks_cluster.cluster_provider_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:ghostcms:ghostcms-sa"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(module.eks_cluster.cluster_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    effect = "Allow"
  }
}



# # Role
resource "aws_iam_role" "ghostcms_iam_role" {

  assume_role_policy  = data.aws_iam_policy_document.ghostcms_iam_policy.json
  name                = "ghostcms-iam-role"
  managed_policy_arns = [aws_iam_policy.ghostcms_iam_policy.arn]
}

# # Policy
resource "aws_iam_policy" "ghostcms_iam_policy" {

  name = "ghostcms-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "s3:*"
      ]
      Resource = ["*"]
    }]
  })
}







resource "kubernetes_manifest" "ghostcms_secret_provider_class" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "spc-ghostcms"
      namespace = "ghostcms"
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = <<-EOT
          - objectName: "sm-ghostcms"
            objectType: "secretsmanager"
            jmesPath:

              - path: REDIS_HOST
                objectAlias: REDIS_HOST
              - path: REDIS_URL
                objectAlias: REDIS_URL
              - path: database__connection__host
                objectAlias: database__connection__host
              - path: database__connection__user
                objectAlias: database__connection__user
              - path: database__connection__password
                objectAlias: database__connection__password
              - path: database__connection__database
                objectAlias: database__connection__database
              - path: url
                objectAlias: url
              - path: accessKeyId
                objectAlias: accessKeyId
              - path: bucket
                objectAlias: bucket
              - path: secretAccessKey
                objectAlias: secretAccessKey
              - path: GHOST_STORAGE_ADAPTER_S3_ASSET_HOST  
                objectAlias: GHOST_STORAGE_ADAPTER_S3_ASSET_HOST  

          EOT
      }
      secretObjects = [{
        secretName = "secret-ghostcms"
        type       = "Opaque"
        data = [

          { objectName = "REDIS_HOST", key = "REDIS_HOST" },
          { objectName = "REDIS_URL", key = "REDIS_URL" },
          { objectName = "database__connection__host", key = "database__connection__host" },
          { objectName = "database__connection__user", key = "database__connection__user" },
          { objectName = "database__connection__password", key = "database__connection__password" },
          { objectName = "database__connection__database", key = "database__connection__database" },
          { objectName = "url", key = "url" },
          { objectName = "accessKeyId", key = "accessKeyId" },
          { objectName = "secretAccessKey", key = "secretAccessKey" },
          { objectName = "bucket", key = "bucket" },
          { objectName = "GHOST_STORAGE_ADAPTER_S3_ASSET_HOST", key = "GHOST_STORAGE_ADAPTER_S3_ASSET_HOST" }
        ]
      }]
    }
  }
}
