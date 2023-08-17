provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "argocd-namespace" {
  metadata {
    name = var.argocd-namespace
  }
}

resource "helm_release" "argo-cd" {
  depends_on = [kubernetes_namespace.argocd-namespace]
  name       = "argo-cd"
  namespace   = var.argocd-namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    file("${path.module}/data/argocd-values.yaml")
  ]
}


provider "kubernetes" {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }

}

data "kubernetes_service" "argo-cd" {
  depends_on = [helm_release.argo-cd]
  metadata {
    name = "argo-cd"
  }
}