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
        container {
          name = "frontend"
          image = var.frontend_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
            name = "frontend"
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