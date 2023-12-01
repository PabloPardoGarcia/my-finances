resource "kubernetes_namespace" "my_finances_namespace" {
  metadata {
    name = "my-finances"
  }
}

module "db" {
  source = "./modules/db"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  pvc_name = "my-finances-postgres-pvc"
  pv_name = "my-finances-postgres-pv"
  pv_path = abspath("../db")
  pv_capacity = "250Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = "my-finances-local-storage-class"
  db_name = "${kubernetes_namespace.my_finances_namespace.metadata.0.name}-postgres"
}

module "dbt" {
  source = "./modules/dbt"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  dbt_image = "my-finances-dbt"
  git_sync_git_repo = "https://github.com/PabloPardoGarcia/my-finances"
  git_sync_image = "registry.k8s.io/git-sync/git-sync:v4.0.0"
  git_sync_path_to_dbt = "my-finances/dbt/my_finances"
  git_sync_path_to_dbt_profiles = "my-finances/dbt/profiles.yml"
  postgres_service_name = module.db.service_name
  postgres_secrets_name = module.db.secret_name
}

module "api" {
  source = "./modules/api"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  api_image = "my-finances-api"
  postgres_service_name = module.db.service_name
  postgres_secrets_name = module.db.secret_name
}

module "ingress_controller" {
  source = "./modules/ingress"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  site_url = "mysites.internal"
  dbt_service_name = module.dbt.service_name
  api_service_name = module.api.service_name
}