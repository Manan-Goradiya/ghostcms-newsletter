resource "kubernetes_cron_job_v1" "on-demand-spot-job" {
  metadata {
    name      = "on-demand-to-spt-job"
    namespace = "ghostcms" # Adjust namespace as needed
  }

  spec {
    concurrency_policy = "Replace"
    schedule           = "59 18 * * *"       # 18:59 UTC = 23:59 IST (UTC+5:30)
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            # Service account with permissions to list namespaces
            service_account_name = kubernetes_service_account.job_sa.metadata[0].name
            container {
              name    = "list-namespaces"
              image   = "bitnami/kubectl:latest" # Official kubectl image
              command = ["/bin/sh", "-c"]
              #   args    = ["kubectl get ns -o name | tee /dev/stderr"]
              args = [
                        "/bin/sh",
                        "-c",
                            <<-EOT
                kubectl patch deployment ghost -n ghostcms \
                --type='json' \
                -p='[{
                    \"op\": \"replace\",
                    \"path\": \"/spec/template/spec/affinity/nodeAffinity/requiredDuringSchedulingIgnoredDuringExecution/nodeSelectorTerms/0/matchExpressions/0/values/0\",
                    \"value\": \"ghostcms-stag-spot\"
                }]'
        EOT
              ]


            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}


resource "kubernetes_cron_job_v1" "spot-on-demand-job" {
  metadata {
    name      = "spot-on-demand-job"
    namespace = "ghostcms" # Adjust namespace as needed
  }

  spec {
    concurrency_policy = "Replace"
    schedule           = "30 2 * * *"  # 02:30 UTC = 08:00 IST
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            # Service account with permissions to list namespaces
            service_account_name = kubernetes_service_account.job_sa.metadata[0].name
            container {
              name    = "list-namespaces"
              image   = "bitnami/kubectl:latest" # Official kubectl image
              command = ["/bin/sh", "-c"]
              #   args    = ["kubectl get ns -o name | tee /dev/stderr"]
              args = [
                        "/bin/sh",
                        "-c",
                            <<-EOT
                kubectl patch deployment ghost -n ghostcms \
                --type='json' \
                -p='[{
                    \"op\": \"replace\",
                    \"path\": \"/spec/template/spec/affinity/nodeAffinity/requiredDuringSchedulingIgnoredDuringExecution/nodeSelectorTerms/0/matchExpressions/0/values/0\",
                    \"value\": \"ghostcms-stag\"
                }]'
        EOT
              ]


            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}

# Service account for the job
resource "kubernetes_service_account" "job_sa" {
  metadata {
    name      = "job-sa"
    namespace = "ghostcms"
  }
}

# Role with permissions to list namespaces
resource "kubernetes_role" "job_role" {
  metadata {
    name      = "job-role"
    namespace = "ghostcms"
  }

  # Rule for namespace operations
  rule {
    api_groups = [""] # Core API group
    resources  = ["namespaces"]
    verbs      = ["get", "list"]
  }

  # Rule for deployment operations
  rule {
    api_groups = ["apps"] # API group for Deployments
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "patch", "update"]
  }
}

# Bind the role to the service account
resource "kubernetes_role_binding" "job_role_binding" {
  metadata {
    name      = "job-role-binding"
    namespace = "ghostcms"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.job_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.job_sa.metadata[0].name
    namespace = "ghostcms"
  }
}