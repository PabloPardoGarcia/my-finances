module "my-finances-postgres-volume" {
  source = "../local_volume"
  namespace = var.namespace
  pvc_name = "my-finances-postgres-pvc"
  pv_name = "my-finances-postgres-pv"
  pv_path = abspath("../db")
  pv_capacity = "250Mi"
  pv_node_names = ["docker-desktop"]
  storage_class_name = var.storage_class_name
  labels = {
    "app.kubernetes.io/name": var.namespace,
    "app.kubernetes.io/component": "postgres-volume"
  }
}

module "postgres" {
  source = "../postgres"
  postgres_namespace = var.namespace
  postgres_pvc_name = module.my-finances-postgres-volume.pvc-name
  postgres_pv_name = module.my-finances-postgres-volume.pv-name
  postgres_name = "${var.namespace}-postgres"
  postgres_labels = {
    "app.kubernetes.io/name": var.namespace,
    "app.kubernetes.io/component": "postgres"
  }

  postgres_user = data.sops_file.db-secret.data["user"]
  postgres_password = data.sops_file.db-secret.data["password"]
  postgres_db_name = data.sops_file.db-secret.data["db"]
}

resource "kubernetes_secret_v1" "git-credentials" {
  metadata {
    name = "git-credentials"
    namespace = var.namespace
  }
  data = {
    "ssh": base64encode(jsonencode(data.sops_file.git-sync-secret.data["ssh-key-file"]))
    "known_hosts": base64encode(jsonencode(data.sops_file.git-sync-secret.data["known-hosts"]))
  }
}

resource "kubernetes_deployment_v1" "my-finances-dbt-deployment" {
  metadata {
    name = "${var.namespace}-dbt"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "dbt"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {"app.kubernetes.io/name": var.namespace}
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name": var.namespace,
          "app.kubernetes.io/component": "dbt"
        }
      }
      spec {
        volume {
          name = "git-sync-content"
        }
        volume {
          name = "git-sync-secret"
          secret {
            secret_name = kubernetes_secret_v1.git-credentials.metadata.0.name
            default_mode = "0400"
          }
        }

        init_container {
          name = "dbt-repo-setup"
          image = var.git_sync_image
          args = [
            "--repo=${var.git_sync_git_repo}",
            "--branch=master",
            "--depth=1",
            "--max-failures=6",
            "--one-time=true",  # exit after the first sync (we just want to initialize the file system)
            "--period=10s",
            "--root=/git",
            "--ssh=true",
            "--ssh-known-hosts=true"
          ]
          security_context {
            run_as_user = "65533" # git-sync-user
          }
          volume_mount {
            mount_path = "/git"
            name       = "git-sync-content"
          }
          volume_mount {
            mount_path = "/etc/git-secret"
            name       = "git-sync-secret"
            read_only = true
          }
        }

        container {
          name  = "dbt"
          image = var.dbt_image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
            name           = "docs-port"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value = data.sops_file.db-secret.data["password"]
          }
          env {
            name = "POSTGRES_USER"
            value = data.sops_file.db-secret.data["user"]
          }
          env {
            name = "POSTGRES_DB"
            value = data.sops_file.db-secret.data["db"]
          }
          env {
            name = "POSTGRES_HOST"
            value = module.postgres.service-name
          }

          volume_mount {
            mount_path = "/usr/app"
            name       = "git-sync-content"
            sub_path   = var.git_sync_path_to_dbt
          }
          volume_mount {
            mount_path = "/root/.dbt/profiles.yml"
            name       = "git-sync-content"
            sub_path   = var.git_sync_path_to_dbt_profiles
            read_only = true
          }
        }

        container {
          name = "git-sync"
          image = var.git_sync_image
          args = [
            "--repo=${var.git_sync_git_repo}",
            "--branch=master",
            "--depth=1",
            "--max-failures=-1",
            "--period=60s",
            "--root=/git",
            "--add-user",
            "--ssh",
            "--ssh-known-hosts"
          ]
          security_context {
            run_as_user = "65533" # git-sync-user
          }
          volume_mount {
            mount_path = "/git"
            name       = "git-sync-content"
          }
          volume_mount {
            mount_path = "/etc/git-secret"
            name       = "git-sync-secret"
            read_only = true
          }
        }

        security_context {
          fs_group = "65533" # git-sync-user
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "my-finances-dbt-service" {
  metadata {
    name = "${var.namespace}-dbt"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name": var.namespace,
      "app.kubernetes.io/component": "dbt"
    }
  }
  spec {
    type = "NodePort"
    port {
      name = "http"
      port = 80
      target_port = "docs-port"
    }
    selector = {
      "app.kubernetes.io/name": var.namespace
    }
  }
}

resource "kubernetes_ingress_v1" "my-finances-ingress" {
  metadata {
    namespace = var.namespace
    name = "my-finances-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex" = "true"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET, OPTIONS, HEAD"

    }
  }
  spec {
    rule {
      host = var.site_url
      http {
        path {
          path = "/dbt(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.my-finances-dbt-service.metadata.0.name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

