resource "kubernetes_deployment_v1" "postgres_deployment" {
  metadata {
    name = var.postgres_name
    namespace = var.postgres_namespace
  }
  spec {
    replicas = "1"
    selector {
      match_labels = var.postgres_labels
    }
    template {
      metadata {
        labels = var.postgres_labels
      }
      spec {
        volume {
          name = var.postgres_pv_name
          persistent_volume_claim {
            claim_name = var.postgres_pvc_name
          }
        }
        container {
          name = "postgres"
          image = "postgres"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_PASSWORD"
            value = var.postgres_password
          }
          env {
            name = "POSTGRES_USER"
            value = var.postgres_user
          }
          env {
            name = "POSTGRES_DB"
            value = var.postgres_db_name
          }

          # TODO: Mount postgres data to local data
#          volume_mount {
#            mount_path = "/var/lib/postgresql/data"
#            name       = var.postgres_pv_name
#          }

          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name       = var.postgres_pv_name
          }
        }

      }
    }
  }
}

resource "kubernetes_service_v1" "postgres_service" {
  metadata {
    name = var.postgres_name
    namespace = var.postgres_namespace
    labels = var.postgres_labels
  }
  spec {
    type = "NodePort"
    port {
      port = 5432
    }
    selector = var.postgres_labels
  }
}