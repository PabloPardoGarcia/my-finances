resource "kubernetes_namespace" "my-finances-namespace" {
  metadata {
    name = "my-finances"
  }
}

module "local-storage-class" {
  source = "./modules/storage"
  local_storage_class_name = "local-storage-class"
}

module "my-finances-postgres-volume" {
  source = "./modules/local_volume"
  local_volume_name = "my-finances-postgres-pv"
  local_volume_path = "/Users/pablo/Documents/projects/my_finances/db"
  local_volume_capacity = "500Mi"
  local_volume_node_names = ["docker-desktop"]
  storage_class_name = "local-storage-class"
  pvc_namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
  pvc_name = "my-finances-postgres-pvc"
}

module "postgres" {
  source = "./modules/postgres"

  postgres_namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
  postgres_pvc_name = "my-finances-postgres-pvc"
  postgres_pv_name = "my-finances-postgres-pv"
  postgres_name = "my-finances-postgres"
}

module "my-finances-dbt-volume" {
  source = "./modules/local_volume"
  local_volume_name = "my-finances-dbt-pv"
  local_volume_path = "/Users/pablo/Documents/projects/my_finances/dbt"
  local_volume_capacity = "200Mi"
  local_volume_node_names = ["docker-desktop"]
  storage_class_name = "local-storage-class"
  pvc_namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
  pvc_name = "my-finances-dbt-pvc"
}

module "my_finances" {
  source = "./modules/my_finances"
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name

  dbt_deployment_name = "my-finances-dbt"
  dbt_pvc_name = "my-finances-dbt-pvc"
  dbt_pv_name = "my-finances-dbt-pv"
  dbt_pv_path_to_app = "my_finances"
  dbt_pv_path_to_profiles = "profiles.yml"
  dbt_image = "custom-dbt-postgres-1.6.6"
}