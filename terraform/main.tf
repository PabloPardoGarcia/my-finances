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
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
  pvc_name = "my-finances-postgres-pvc"
  pv_name = "my-finances-postgres-pv"
  pv_path = abspath("../db")
  pv_capacity = "500Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = module.local-storage-class.storage-class-name
}

module "postgres" {
  source = "./modules/postgres"

  postgres_namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
  postgres_pvc_name = module.my-finances-postgres-volume.pvc-name
  postgres_pv_name = module.my-finances-postgres-volume.pv-name
  postgres_name = "my-finances-postgres"
}

module "my-finances-dbt-volume" {
  source = "./modules/local_volume"
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
  pvc_name = "my-finances-dbt-pvc"
  pv_name = "my-finances-dbt-pv"
  pv_path = abspath("../dbt")
  pv_capacity = "200Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = module.local-storage-class.storage-class-name
}

module "my_finances" {
  source = "./modules/my_finances"
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name

  dbt_deployment_name = "my-finances-dbt"
  dbt_pvc_name = module.my-finances-dbt-volume.pvc-name
  dbt_pv_name = module.my-finances-dbt-volume.pv-name
  dbt_pv_path_to_app = "my_finances"
  dbt_pv_path_to_profiles = "profiles.yml"
  dbt_image = "custom-dbt-postgres-1.6.6"
}