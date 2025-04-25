module "redis-cluster" {
depends_on = [module.eks_cluster]
source= "../modules/redis"
environment = "redis"
providers = {
    helm = helm
    kubernetes = kubernetes
  }
}



