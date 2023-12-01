resource "kubernetes_storage_class_v1" "local_storage_class" {
  storage_provisioner = "kubernetes.io/no-provisioner"
  metadata {
    name = var.storage_class_name
  }
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "kubernetes_persistent_volume_v1" "local_pv" {
  metadata {
    name = var.pv_name
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "postgres"
    }
  }
  spec {
    access_modes = var.pv_access_modes
    capacity     = {
      storage = var.pv_capacity
    }
    persistent_volume_source {
      local {
        path = var.pv_path
      }
    }
    persistent_volume_reclaim_policy = "Retain"
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values = var.pv_node_names
          }
        }
      }
    }
    storage_class_name = kubernetes_storage_class_v1.local_storage_class.metadata.0.name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "local_pvc" {
  count = var.create_pvc == true ? 1 : 0
  metadata {
    name = var.pvc_name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "postgres"
    }
  }
  spec {
    access_modes = var.pvc_access_modes
    storage_class_name = kubernetes_storage_class_v1.local_storage_class.metadata.0.name
    resources {
      requests = {
        storage = var.pv_capacity
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_secret_v1" "postgres_credentials" {
  metadata {
    name = "postgres-credentials"
    namespace = var.namespace
  }
  data = {
    "user": base64encode(jsonencode(data.sops_file.db_secret.data["user"]))
    "password": base64encode(jsonencode(data.sops_file.db_secret.data["password"]))
    "db": base64encode(jsonencode(data.sops_file.db_secret.data["db"]))
  }
}

resource "kubernetes_deployment_v1" "postgres_deployment" {
  metadata {
    name = var.db_name
    namespace = var.namespace
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name": var.namespace,
        "app.kubernetes.io/component": "postgres"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name": var.namespace,
          "app.kubernetes.io/component": "postgres"
        }
      }
      spec {
        volume {
          name = kubernetes_persistent_volume_v1.local_pv.metadata.0.name
          persistent_volume_claim {
            claim_name = one(kubernetes_persistent_volume_claim_v1.local_pvc[*].metadata.0.name)
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
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.postgres_credentials.metadata.0.name
                key = "password"
              }
            }
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.postgres_credentials.metadata.0.name
                key = "user"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.postgres_credentials.metadata.0.name
                key = "db"
              }
            }
          }

          # TODO: Mount postgres data to local data
#          volume_mount {
#            mount_path = "/var/lib/postgresql/data"
#            name       = var.postgres_pv_name
#          }

          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name       = kubernetes_persistent_volume_v1.local_pv.metadata.0.name
          }
        }

      }
    }
  }
}

resource "kubernetes_service_v1" "postgres_service" {
  metadata {
    name = var.db_name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "postgres"
    }
  }
  spec {
    type = "NodePort"
    port {
      port = 5432
    }
    selector = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "postgres"
    }
  }
}