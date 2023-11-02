resource "kubernetes_persistent_volume_v1" "local-volume" {
  metadata {
    name = var.local_volume_name
  }
  spec {
    access_modes = var.local_volume_access_modes
    capacity     = {
      storage = var.local_volume_capacity
    }
    persistent_volume_source {
      local {
        path = var.local_volume_path
      }
    }
    persistent_volume_reclaim_policy = "Retain"
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values = var.local_volume_node_names
          }
        }
      }
    }
    storage_class_name = var.storage_class_name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "local-pvc" {
  metadata {
    name = var.pvc_name
    namespace = var.pvc_namespace
  }
  spec {
    access_modes = var.pvc_access_modes
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.local_volume_capacity
      }
    }
  }
}