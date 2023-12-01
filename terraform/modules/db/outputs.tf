output "secret_name" {
  value = kubernetes_secret_v1.postgres_credentials.metadata.0.name
}

output "service_name" {
  value = kubernetes_service_v1.postgres_service.metadata.0.name
}