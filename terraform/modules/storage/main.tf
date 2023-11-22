resource "kubernetes_storage_class_v1" "local_storage_class" {
  storage_provisioner = "kubernetes.io/no-provisioner"
  metadata {
    name = var.local_storage_class_name
  }
  volume_binding_mode = "WaitForFirstConsumer"
}