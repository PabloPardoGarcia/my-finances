resource "helm_release" "lightdash_release" {
  name = "lightdash"
  repository = "https://lightdash.github.io/helm-charts"
  chart = "lightdash"

  version = var.helm_version
  namespace = var.namespace

  # Overwrite helm chart values.yaml
  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_ingress_v1" "lightdash-ingress" {
  metadata {
    namespace = var.namespace
    name = "lightdash-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex" = "true"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "PUT, GET, POST, OPTIONS, HEAD"
    }
  }
  spec {
    rule {
      host = var.site_url
      http {
        path {
          path = "/lightdash(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "lightdash"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}