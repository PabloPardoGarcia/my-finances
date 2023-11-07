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

  git_sync_path_to_dbt = "my-finances/dbt/my_finances"
  git_sync_path_to_dbt_profiles = "my-finances/dbt/profiles.yml"
  git_sync_git_repo = "https://github.com/PabloPardoGarcia/my-finances"
  git_sync_image = "registry.k8s.io/git-sync/git-sync:v4.0.0"
  dbt_image = "custom-dbt-postgres-1.6.6"
}

module "lightdash" {
  source = "./modules/lightdash"
  namespace = kubernetes_namespace.my-finances-namespace.metadata.0.name
}