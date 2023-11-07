module "my-finances-postgres-volume" {
  source = "../local_volume"
  namespace = var.namespace
  pvc_name = "my-finances-postgres-pvc"
  pv_name = "my-finances-postgres-pv"
  pv_path = abspath("../db")
  pv_capacity = "500Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = var.storage_class_name
  labels = {
    "app.kubernetes.io/name": var.namespace,
    "app.kubernetes.io/component": "postgres-volume"
  }
}

module "postgres" {
  source = "../postgres"
  postgres_namespace = var.namespace
  postgres_pvc_name = module.my-finances-postgres-volume.pvc-name
  postgres_pv_name = module.my-finances-postgres-volume.pv-name
  postgres_name = "${var.namespace}-postgres"
  postgres_labels = {
    "app.kubernetes.io/name": var.namespace,
    "app.kubernetes.io/component": "postgres"
  }

  postgres_user = data.sops_file.db-secret.data["user"]
  postgres_password = data.sops_file.db-secret.data["password"]
  postgres_db_name = data.sops_file.db-secret.data["db"]
}

module "my-finances-dbt-volume" {
  source = "../local_volume"
  namespace = var.namespace
  pv_name = "${var.namespace}-dbt-pv"
  pv_path = abspath("../dbt")
  pv_capacity = "300Mi"
  pv_node_names = ["docker-desktop"]
  pv_access_modes = ["ReadWriteOnce"]
  storage_class_name = var.storage_class_name
  labels = {
    "app.kubernetes.io/name": var.namespace,
    "app.kubernetes.io/component": "dbt-volume"
  }
  create_pvc = false
}

resource "kubernetes_stateful_set_v1" "my-finances-dbt-stateful-set" {
  metadata {
    name = "${var.namespace}-dbt"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "dbt"
    }
  }
  spec {
    service_name = "${var.namespace}-dbt"
    selector {
      match_labels = {"app.kubernetes.io/name": var.namespace}
    }
    replicas = "1"
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name": var.namespace,
          "app.kubernetes.io/component": "dbt"
        }
      }
      spec {
        termination_grace_period_seconds = 10
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
            value = data.sops_file.db-secret.data["password"]
          }
          env {
            name = "POSTGRES_USER"
            value = data.sops_file.db-secret.data["user"]
          }
          env {
            name = "POSTGRES_DB"
            value = data.sops_file.db-secret.data["db"]
          }
          env {
            name = "POSTGRES_HOST"
            value = module.postgres.service-name
          }

          volume_mount {
            mount_path = "/usr/app"
            name       = "${var.namespace}-dbt-pvc"
            sub_path   = var.dbt_pv_path_to_app
          }

          volume_mount {
            mount_path = "/root/.dbt/profiles.yml"
            name       = "${var.namespace}-dbt-pvc"
            sub_path   = var.dbt_pv_path_to_profiles
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "${var.namespace}-dbt-pvc"
        namespace = var.namespace
        labels = {
          "app.kubernetes.io/name": var.namespace,
          "app.kubernetes.io/component": "dbt-volume"
        }
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = var.storage_class_name
        resources {
          requests = {
            storage = module.my-finances-dbt-volume.pv-volume-capacity
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "my-finances-dbt-service" {
  metadata {
    name = "${var.namespace}-dbt"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "dbt"
    }
  }
  spec {
    type = "NodePort"
    port {
      name = "dbt-docs-port"
      port = 80
      target_port = "docs-port"
    }
    selector = {
      "app.kubernetes.io/name": var.namespace
    }
  }
}