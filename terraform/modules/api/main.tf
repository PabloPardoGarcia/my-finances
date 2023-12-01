resource "kubernetes_deployment_v1" "my_finances_api_deployment" {
  metadata {
    name = "${var.namespace}-api"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "api"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name": var.namespace
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name": var.namespace,
          "app.kubernetes.io/component": "api"
        }
      }
      spec {
        container {
          name = "api"
          image = var.api_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
            name = "api"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.postgres_secrets_name
                key = "password"
              }
            }
          }
          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = var.postgres_secrets_name
                key  = "user"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = var.postgres_secrets_name
                key = "db"
              }
            }
          }
          env {
            name = "POSTGRES_HOST"
            value = var.postgres_service_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "my_finances_api_service" {
  metadata {
    name = "${var.namespace}-api"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "api"
    }
  }
  spec {
    type = "NodePort"
    port {
      name = "http"
      port = 80
      target_port = "api"
    }
    selector = {
      "app.kubernetes.io/component": "api"
    }
  }
}