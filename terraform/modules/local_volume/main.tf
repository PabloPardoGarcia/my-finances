resource "kubernetes_persistent_volume_v1" "local-volume" {
  metadata {
    name = var.pv_name
    labels = var.labels
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
    storage_class_name = var.storage_class_name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "local-pvc" {
  count = var.create_pvc == true ? 1 : 0
  metadata {
    name = var.pvc_name
    namespace = var.namespace
    labels = var.labels
  }
  spec {
    access_modes = var.pvc_access_modes
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.pv_capacity
      }
    }
  }
  wait_until_bound = false
}