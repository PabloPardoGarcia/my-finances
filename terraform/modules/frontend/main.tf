resource "kubernetes_deployment_v1" "my_finances_frontend_deployment" {
  metadata {
    name = "${var.namespace}-frontend"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "frontend"
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
          "app.kubernetes.io/component": "frontend"
        }
      }
      spec {
        image_pull_secrets {
          name = var.docker_config_secret
        }

        container {
          name = "frontend"
          image = var.frontend_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
            name = "frontend"
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
                key = "user"
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

resource "kubernetes_service_v1" "my_finances_frontend_service" {
  metadata {
    name = "${var.namespace}-frontend"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "frontend"
    }
  }
  spec {
    type = "NodePort"
    port {
      name = "http"
      port = 80
      target_port = "frontend"
    }
    selector = {
      "app.kubernetes.io/component": "frontend"
    }
  }
}