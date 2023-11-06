output "service-name" {
  value = kubernetes_service_v1.postgres-service.metadata.0.name
}