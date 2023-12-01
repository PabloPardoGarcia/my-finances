resource "helm_release" "ingress_nginx_release" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  create_namespace = true
  namespace = var.ingres_controller_namespace
  version = var.helm_version
}

resource "kubernetes_ingress_v1" "my_finances_ingress" {
  metadata {
    namespace = var.namespace
    name = "my-finances-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex" = "true"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "POST, PUT, PATCH, GET, OPTIONS, HEAD"
    }
  }
  spec {
    rule {
      host = var.site_url
      http {
        path {
          path = "/()(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = var.frontend_service_name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }

    rule {
      host = var.site_url
      http {
        path {
          path = "/(api[/|$])(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = var.api_service_name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }

    rule {
      host = var.site_url
      http {
        path {
          path = "/(dbt[/|$]?)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = var.dbt_service_name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}