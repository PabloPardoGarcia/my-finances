output "storage_class_name" {
  value = kubernetes_storage_class_v1.local_storage_class.metadata.0.name
}