output "storage-class-name" {
  value = kubernetes_storage_class_v1.local-storage-class.metadata.0.name
}