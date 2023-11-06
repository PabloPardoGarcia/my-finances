module "my-finances-postgres-volume" {
  source = "../local_volume"
  namespace = var.namespace
  pvc_name = "my-finances-postgres-pvc"
  pv_name = "my-finances-postgres-pv"
  pv_path = abspath("../db")
  pv_capacity = "500Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = var.storage_class_name
}

module "postgres" {
  source = "../postgres"
  postgres_namespace = var.namespace
  postgres_pvc_name = module.my-finances-postgres-volume.pvc-name
  postgres_pv_name = module.my-finances-postgres-volume.pv-name
  postgres_name = "my-finances-postgres"
  postgres_labels = var.labels
}

module "my-finances-dbt-volume" {
  source = "../local_volume"
  namespace = var.namespace
  pvc_name = "my-finances-dbt-pvc"
  pv_name = "my-finances-dbt-pv"
  pv_path = abspath("../dbt")
  pv_capacity = "200Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = var.storage_class_name
}

resource "kubernetes_deployment_v1" "my-finances-dbt-deployment" {
  metadata {
    name = "my-finances-dbt"
    namespace = var.namespace
  }
  spec {
    replicas = "1"
    selector {
      match_labels = var.labels
    }
    template {
      metadata {
        labels = var.labels
      }
      spec {
        volume {
          name = module.my-finances-dbt-volume.pv-name
          persistent_volume_claim {
            claim_name = module.my-finances-dbt-volume.pvc-name
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
            name       = module.my-finances-dbt-volume.pv-name
            sub_path   = var.dbt_pv_path_to_app
          }

          volume_mount {
            mount_path = "/root/.dbt/profiles.yml"
            name       = module.my-finances-dbt-volume.pv-name
            sub_path   = var.dbt_pv_path_to_profiles
          }

        }
      }
    }
  }
}

resource "kubernetes_service_v1" "my-finances-dbt-service" {
  metadata {
    name = "my-finances-dbt"
    namespace = var.namespace
    labels = var.labels
  }
  spec {
    type = "NodePort"
    port {
      name = "dbt-docs-port"
      port = 80
      target_port = "docs-port"
    }
    selector = var.labels
  }
}