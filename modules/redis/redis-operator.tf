resource "helm_release" "tz-dev-stag-redis-operator" {
  provider = helm
  name       = "${var.environment}-redis-operator"
  namespace  = "${var.environment}" #kubernetes_namespace.tz-jsw-prod.metadata[0].name
  repository = "https://spotahome.github.io/redis-operator"
  chart      = "redis-operator"
  version    = "3.2.9"
  values     = [ file("${path.module}/dev-stag-redis-operator-values.yaml") ]


set {
  name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]"
  value = "${var.environment}"
}

}

