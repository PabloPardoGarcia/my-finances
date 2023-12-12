resource "kubernetes_namespace" "my_finances_namespace" {
  metadata {
    name = "my-finances"
  }
}

resource "kubernetes_secret_v1" "docker_config" {
  type = "kubernetes.io/dockerconfigjson"
  metadata {
    name = "docker-config"
    namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
    labels = {
      "app.kubernetes.io/name" : kubernetes_namespace.my_finances_namespace.metadata.0.name
    }
  }
  data = {
    ".dockerconfigjson": jsonencode({
      "auths" = {
        "https://ghcr.io" = {
          "auth": base64encode("${data.sops_file.dockerconfig_secret.data["username"]}:${data.sops_file.dockerconfig_secret.data["github_pat"]}")
        }
      }
    })
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
  dbt_image = "ghcr.io/pablopardogarcia/my-finances-dbt:latest"
  postgres_service_name = module.db.service_name
  postgres_secrets_name = module.db.secret_name
  docker_config_secret = kubernetes_secret_v1.docker_config.metadata.0.name
}

module "api" {
  source = "./modules/api"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  api_image = "ghcr.io/pablopardogarcia/my-finances-api:latest"
  postgres_service_name = module.db.service_name
  postgres_secrets_name = module.db.secret_name
  docker_config_secret = kubernetes_secret_v1.docker_config.metadata.0.name
}

module "frontend" {
  source = "./modules/frontend"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  frontend_image = "ghcr.io/pablopardogarcia/my-finances-frontend:latest"
  postgres_service_name = module.db.service_name
  postgres_secrets_name = module.db.secret_name
  docker_config_secret = kubernetes_secret_v1.docker_config.metadata.0.name
}

module "ingress_controller" {
  source = "./modules/ingress"
  namespace = kubernetes_namespace.my_finances_namespace.metadata.0.name
  site_url = "mysites.internal"
  dbt_service_name = module.dbt.service_name
  api_service_name = module.api.service_name
  frontend_service_name = module.frontend.service_name
}
