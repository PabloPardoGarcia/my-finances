output "service_name" {
  value = kubernetes_service_v1.my_finances_dbt_service.metadata.0.name
}