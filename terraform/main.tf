resource "kubernetes_namespace" "my-finances-namespace" {
  metadata {
    name = "my-finances"
  }
}

module "local-storage-class" {
  source = "./modules/storage"
}

module "my_finances" {
  source = "./modules/my_finances"
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name

  dbt_pv_path_to_app = "my_finances"
  dbt_pv_path_to_profiles = "profiles.yml"
  dbt_image = "custom-dbt-postgres-1.6.6"
}

module "lightdash" {
  source = "./modules/lightdash"
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
}