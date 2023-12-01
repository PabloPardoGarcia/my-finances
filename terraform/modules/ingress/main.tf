resource "helm_release" "ingress_nginx_release" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  create_namespace = true
  namespace = var.namespace
  version = var.helm_version

  values = [

  ]
}
