resource "kubernetes_deployment_v1" "my-finances-dbt-deployment" {
  metadata {
    name = var.dbt_deployment_name
    namespace = var.namespace
  }
  spec {
    replicas = "1"
    selector {
      match_labels = var.dbt_labels
    }
    template {
      metadata {
        labels = var.dbt_labels
      }
      spec {
        volume {
          name = var.dbt_pv_name
          persistent_volume_claim {
            claim_name = var.dbt_pvc_name
          }
        }
        container {
          name  = "dbt"
          image = "custom-dbt-postgres-1.6.6"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
            name           = "docs-port"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value = "example"
          }
          env {
            name = "POSTGRES_USER"
            value = "example"
          }
          env {
            name = "POSTGRES_DB"
            value = "myfinances"
          }
          env {
            name = "POSTGRES_HOST"
            value = "my-finances-postgres"
          }

          volume_mount {
            mount_path = "/usr/app"
            name       = var.dbt_pv_name
            sub_path   = var.dbt_pv_path_to_app
          }

          volume_mount {
            mount_path = "/root/.dbt/profiles.yml"
            name       = var.dbt_pv_name
            sub_path   = var.dbt_pv_path_to_profiles
          }

        }
      }
    }
  }
}

resource "kubernetes_service_v1" "my-finances-dbt-service" {
  metadata {
    name = var.dbt_deployment_name
    namespace = var.namespace
    labels = var.dbt_labels
  }
  spec {
    type = "NodePort"
    port {
      name = "dbt-docs-port"
      port = 80
      target_port = "docs-port"
    }
    selector = var.dbt_labels
  }
}