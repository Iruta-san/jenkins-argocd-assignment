resource "kubernetes_manifest" "argocd-testapp" {
    depends_on = [helm_release.argo-cd]
    manifest = yamldecode(file("../argocd-manifest.yaml"))
}